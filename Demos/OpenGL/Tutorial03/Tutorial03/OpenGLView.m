//
//  OpenGLView.m
//  Tutorial01
//
//  Created by kesalin on 12-11-24.
//  Copyright (c) 2012年 Created by kesalin@gmail.com on. All rights reserved.
//

#import "OpenGLView.h"
#import "GLESUtils.h"


// 使用匿名 category 来声明私有成员
@interface OpenGLView()
{
    CADisplayLink * _displayLink;
}

- (void)setupLayer;
- (void)setupContext;
- (void)setupBuffers;
- (void)destoryBuffers;

- (void)setupProgram;
- (void)setupProjection;

- (void)updateTransform;
- (void)displayLinkCallback:(CADisplayLink*)displayLink;

@end

@implementation OpenGLView
@synthesize posX = _posX;
@synthesize posY = _posY;
@synthesize posZ = _posZ;
@synthesize scaleZ = _scaleZ;
@synthesize rotateX = _rotateX;

+ (Class)layerClass {
    // 只有 [CAEAGLLayer class] 类型的 layer 才支持在其上描绘 OpenGL 内容。
    return [CAEAGLLayer class];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    
    // CALayer 默认是透明的，必须将它设为不透明才能让其可见
    _eaglLayer.opaque = YES;
    
    // 设置描绘属性，在这里设置不维持渲染内容以及颜色格式为 RGBA8
    _eaglLayer.drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithBool:NO], kEAGLDrawablePropertyRetainedBacking, kEAGLColorFormatRGBA8, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    // 指定 OpenGL 渲染 API 的版本，在这里我们使用 OpenGL ES 2.0 
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@" >> Error: Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 设置为当前上下文
    if (![EAGLContext setCurrentContext:_context]) {
        _context = nil;
        NSLog(@" >> Error: Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupBuffers {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    // 设置为当前 renderbuffer
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    // 为 color renderbuffer 分配存储空间
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    
    glGenFramebuffers(1, &_frameBuffer);
    // 设置为当前 framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    // 将 _colorRenderBuffer 装配到 GL_COLOR_ATTACHMENT0 这个装配点上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, 
                              GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)destoryBuffers
{
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
    
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
}

- (void)cleanup
{
    [self destoryBuffers];
    
    if (_programHandle != 0) {
        glDeleteProgram(_programHandle);
        _programHandle = 0;
    }

    if (_context && [EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    
    _context = nil;
}

- (void)setupProgram
{
    // Load shaders
    //
    NSString * vertexShaderPath = [[NSBundle mainBundle] pathForResource:@"VertexShader"
                                                                  ofType:@"glsl"];
    NSString * fragmentShaderPath = [[NSBundle mainBundle] pathForResource:@"FragmentShader"
                                                                    ofType:@"glsl"];
    
    _programHandle = [GLESUtils loadProgram:vertexShaderPath
                 withFragmentShaderFilepath:fragmentShaderPath];
    if (_programHandle == 0) {
        NSLog(@" >> Error: Failed to setup program.");
        return;
    }
    
    glUseProgram(_programHandle);
    
    // Get the attribute position slot from program
    //
    _positionSlot = glGetAttribLocation(_programHandle, "vPosition");
    
    // Get the uniform model-view matrix slot from program
    //
    _modelViewSlot = glGetUniformLocation(_programHandle, "modelView");
    
    // Get the uniform projection matrix slot from program
    //
    _projectionSlot = glGetUniformLocation(_programHandle, "projection");
}

-(void)setupProjection
{
    // Generate a perspective matrix with a 60 degree FOV
    //
    float aspect = self.frame.size.width / self.frame.size.height;
    ksMatrixLoadIdentity(&_projectionMatrix);
    ksPerspective(&_projectionMatrix, 60.0, aspect, 1.0f, 20.0f);
    
    // Load projection matrix
    glUniformMatrix4fv(_projectionSlot, 1, GL_FALSE, (GLfloat*)&_projectionMatrix.m[0][0]);
}

- (void)updateTransform
{
    // Generate a model view matrix to rotate/translate/scale
    //
    ksMatrixLoadIdentity(&_modelViewMatrix);
    
    // Translate away from the viewer
    //
    ksMatrixTranslate(&_modelViewMatrix, self.posX, self.posY, self.posZ);
    
    // Rotate the triangle
    //
    ksMatrixRotate(&_modelViewMatrix, self.rotateX, 1.0, 0.0, 0.0);
    
    // Scale the triangle
    ksMatrixScale(&_modelViewMatrix, 1.0, 1.0, self.scaleZ);
    
    // Load the model-view matrix
    glUniformMatrix4fv(_modelViewSlot, 1, GL_FALSE, (GLfloat*)&_modelViewMatrix.m[0][0]);
}

- (void)drawTriangle
{
    GLfloat vertices[] = {
        0.0f,  0.7f, 0.0f, 
        -0.7f, -0.7f, 0.0f,
        0.7f,  -0.7f, 0.0f };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw triangle
    //
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

- (void)drawTriCone
{
    GLfloat vertices[] = {
        0.7f, 0.7f, 0.0f, 
        0.7f, -0.7f, 0.0f,
        -0.7f, -0.7f, 0.0f,
        -0.7f, 0.7f, 0.0f, 
        0.0f, 0.0f, -1.0f,
    };
    
    GLubyte indices[] = {
        0, 1, 1, 2, 2, 3, 3, 0,
        4, 0, 4, 1, 4, 2, 4, 3
    };
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, 0, vertices );
    glEnableVertexAttribArray(_positionSlot);
    
    // Draw lines
    //
    glDrawElements(GL_LINES, sizeof(indices)/sizeof(GLubyte), GL_UNSIGNED_BYTE, indices);
}

- (void)render
{
    if (_context == nil)
        return;

    glClearColor(0, 1.0, 0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT);

    // Setup viewport
    //
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);    
    
    //[self drawTriangle];
    [self drawTriCone];

    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupLayer];        
        [self setupContext];
        [self setupProgram];
        [self setupProjection];

        [self resetTransform];
    }

    return self;
}

- (void)layoutSubviews
{
    [EAGLContext setCurrentContext:_context];
    glUseProgram(_programHandle);

    [self destoryBuffers];
    
    [self setupBuffers];
    
    [self updateTransform];

    [self render];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Transform properties

- (void)toggleDisplayLink
{
    if (_displayLink == nil) {
        _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
        [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
    else {
        [_displayLink invalidate];
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
}

- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    self.rotateX += displayLink.duration * 90;
}

- (void)resetTransform
{
    if (_displayLink != nil) {
        [_displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _displayLink = nil;
    }
    
    _posX = 0.0;
    _posY = 0.0;
    _posZ = -5.5;
    
    _scaleZ = 1.0;
    _rotateX = 0.0;
    
    [self updateTransform];
}

- (void)setPosX:(float)x
{
    _posX = x;
    
    [self updateTransform];
    [self render];
}

- (float)posX
{
    return _posX;
}

- (void)setPosY:(float)y
{
    _posY = y;
    
    [self updateTransform];
    [self render];
}

- (float)posY
{
    return _posY;
}

- (void)setPosZ:(float)z
{
    _posZ = z;
    
    [self updateTransform];
    [self render];
}

- (float)posZ
{
    return _posZ;
}

- (void)setScaleZ:(float)scaleZ
{
    _scaleZ = scaleZ;
    
    [self updateTransform];
    [self render];
}

- (float)scaleZ
{
    return _scaleZ;
}

- (void)setRotateX:(float)rotateX
{
    _rotateX = rotateX;
    
    [self updateTransform];
    [self render];
}

- (float)rotateX
{
    return _rotateX;
}

#pragma mark

@end
