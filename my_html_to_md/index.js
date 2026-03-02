const fs = require('fs');
const path = require('path');

// 读取 HTML 文件
function readHtmlFile(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

// 简单的 HTML 转 Markdown 函数
function htmlToMarkdown(html) {
  // 移除脚本和样式
  let markdown = html
    .replace(/<script[\s\S]*?<\/script>/g, '')
    .replace(/<style[\s\S]*?<\/style>/g, '')
    .replace(/<head[\s\S]*?<\/head>/g, '')
    .replace(/<html[\s\S]*?>/g, '')
    .replace(/<\/html>/g, '')
    .replace(/<body[\s\S]*?>/g, '')
    .replace(/<\/body>/g, '');
  
  // 转换标题
  markdown = markdown
    .replace(/<h1[^>]*>([\s\S]*?)<\/h1>/g, '# $1\n\n')
    .replace(/<h2[^>]*>([\s\S]*?)<\/h2>/g, '## $1\n\n')
    .replace(/<h3[^>]*>([\s\S]*?)<\/h3>/g, '### $1\n\n')
    .replace(/<h4[^>]*>([\s\S]*?)<\/h4>/g, '#### $1\n\n')
    .replace(/<h5[^>]*>([\s\S]*?)<\/h5>/g, '##### $1\n\n')
    .replace(/<h6[^>]*>([\s\S]*?)<\/h6>/g, '###### $1\n\n');
  
  // 转换段落
  markdown = markdown
    .replace(/<p[^>]*>([\s\S]*?)<\/p>/g, '$1\n\n');
  
  // 转换粗体和斜体
  markdown = markdown
    .replace(/<strong[^>]*>([\s\S]*?)<\/strong>/g, '**$1**')
    .replace(/<b[^>]*>([\s\S]*?)<\/b>/g, '**$1**')
    .replace(/<em[^>]*>([\s\S]*?)<\/em>/g, '*$1*')
    .replace(/<i[^>]*>([\s\S]*?)<\/i>/g, '*$1*');
  
  // 转换链接
  markdown = markdown
    .replace(/<a[^>]*href="([^"]*)"[^>]*>([\s\S]*?)<\/a>/g, '[$2]($1)');
  
  // 转换图片
  markdown = markdown
    .replace(/<img[^>]*src="([^"]*)"[^>]*alt="([^"]*)"[^>]*>/g, '![$2]($1)')
    .replace(/<img[^>]*src="([^"]*)"[^>]*>/g, '![Image]($1)');
  
  // 转换列表
  markdown = markdown
    .replace(/<ul[^>]*>([\s\S]*?)<\/ul>/g, (match, content) => {
      const items = content
        .replace(/<li[^>]*>([\s\S]*?)<\/li>/g, '- $1\n')
        .trim();
      return items + '\n\n';
    })
    .replace(/<ol[^>]*>([\s\S]*?)<\/ol>/g, (match, content) => {
      const items = content
        .match(/<li[^>]*>([\s\S]*?)<\/li>/g)
        .map((item, index) => `${index + 1}. ${item.replace(/<li[^>]*>([\s\S]*?)<\/li>/g, '$1')}`)
        .join('\n')
        .trim();
      return items + '\n\n';
    });
  
  // 移除其他 HTML 标签
  markdown = markdown
    .replace(/<[^>]*>/g, '')
    .replace(/&nbsp;/g, ' ')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&amp;/g, '&');
  
  // 清理空白
  markdown = markdown
    .replace(/\n{3,}/g, '\n\n')
    .trim();
  
  return markdown;
}

// 处理 raw 文件夹中的所有 HTML 文件
function processHtmlFiles() {
  const rawDir = path.join(__dirname, 'raw');
  const outputDir = path.join(__dirname, 'output');
  
  // 确保输出目录存在
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }
  
  // 读取 raw 目录中的文件
  const files = fs.readdirSync(rawDir);
  
  files.forEach(file => {
    if (path.extname(file).toLowerCase() === '.html') {
      const htmlPath = path.join(rawDir, file);
      const markdownPath = path.join(outputDir, `${path.basename(file, '.html')}.md`);
      
      console.log(`Processing ${file}...`);
      
      try {
        const html = readHtmlFile(htmlPath);
        const markdown = htmlToMarkdown(html);
        fs.writeFileSync(markdownPath, markdown, 'utf8');
        console.log(`Successfully converted ${file} to ${path.basename(markdownPath)}`);
      } catch (error) {
        console.error(`Error processing ${file}:`, error.message);
      }
    }
  });
  
  console.log('Processing complete!');
}

// 运行转换
processHtmlFiles();