import hashlib
import os
import shutil
import uuid

########## 工具方法

def ss_current_level_items(path) -> list[str]:
    dirs = []
    for name in os.listdir(path):
        temp = os.path.join(path, name)
        if temp.endswith('DS_Store'):
            continue
        dirs.append(temp)
    return dirs

def ss_all_level_items(path:str) -> list[str]:
    current_level_items = ss_current_level_items(path)
    ret = []
    for item in current_level_items:
        if os.path.isfile(item):
            ret.append(item)
        elif os.path.isdir(item):
            sub_items = ss_all_level_items(item)
            ret += sub_items
    return ret

def ss_validate_dir(dir:str) -> str:
    if not os.path.exists(dir):
        os.makedirs(dir)
    return dir

def ss_validate_file(file:str) -> str:
    folder = os.path.dirname(file)
    ss_validate_dir(folder)
    return file

def ss_src_folder() -> str:
    ret = '/Users/zzz/Downloads/Beyond/OpenSourceMine/SSCloner/test_from_path'
    return ss_validate_dir(ret)

def ss_dst_folder() -> str:
    ret = '/Users/zzz/Downloads/Beyond/OpenSourceMine/SSCloner/test_to_path'
    return ss_validate_dir(ret)

def ss_backup_folder() -> str:
    to_folder = ss_dst_folder()
    name = os.path.basename(to_folder)
    dir = os.path.dirname(to_folder)
    backup_name = name + '_backup'
    ret = os.path.join(dir, backup_name)
    return ss_validate_dir(ret)

def ss_file_right_part(file:str, folder:str) -> str:
    name = file.replace(folder, '')
    ret = name.strip('/')
    return ret
 
def ss_file_md5(file:str) -> str:
    md5_obj = hashlib.md5()
    with open(file, 'rb') as f:
        while chunk := f.read(4096):
            md5_obj.update(chunk)
    return md5_obj.hexdigest()

def ss_random_familliar_file(file:str) -> str:
    file_name = os.path.basename(file)
    dir = os.path.dirname(file)
    name, ext = os.path.splitext(file_name)

    random = str(uuid.uuid4()).replace('-', '')
    new_name = name + '_' + random
    if ext:
        file_name = new_name + '.' + ext
    else:
        file_name = new_name
    return os.path.join(dir, file_name) 

########## 文件信息

class FileInfo():
    def __init__(self, file:str):
        super().__init__()
        self.__file = file

    def md5(self):
        if not self.__md5:
            self.__md5 = ss_file_md5(self.__file)
        return self.__md5
    
    def size(self):
        if not self.__size:
            self.__size = os.path.getsize(self.__file)
        return self.__size
    
    @staticmethod
    def objects_with_folder(folder:str) -> list:
        files = ss_all_level_items(folder)
        ret = []
        for file in files:
            obj = FileInfo(file)
            ret.append(file)
        return ret
        
def job_copy_files():
    print('拷贝开始...')

    src_folder = ss_src_folder()
    src_files = ss_all_level_items(src_folder)

    dst_folder = ss_dst_folder()
    
    for current_file in src_files:
        right_part = ss_file_right_part(current_file, src_folder)
        dst_file = ss_validate_file(os.path.join(dst_folder, right_part))

        if os.path.exists(dst_file):
            src_md5 = ss_file_md5(current_file)
            dst_md5 = ss_file_md5(dst_file)
            if src_md5 == dst_md5:
                continue

        if os.path.exists(dst_file):
            os.remove(dst_file)
        print('拷贝: ' + current_file)
        shutil.copy(current_file, dst_file)
    print('拷贝结束')

def job_backup_redundant_files():
    print('备份开始...')
    src_folder = ss_src_folder()
    dst_folder = ss_dst_folder()
    dst_files = ss_all_level_items(dst_folder)
    dst_folder_redundant_files = []
    for current_file in dst_files:
        right_part = ss_file_right_part(current_file, dst_folder)
        maybe_ori_path = os.path.join(src_folder, right_part)
        if not os.path.exists(maybe_ori_path):
            dst_folder_redundant_files.append(current_file)

    backup_folder = ss_backup_folder()
    for current_file in dst_folder_redundant_files:
        right_part = ss_file_right_part(current_file, dst_folder)
        backup_file = ss_validate_file(os.path.join(backup_folder, right_part))
        if os.path.exists(backup_file):
            backup_file = ss_validate_file(ss_random_familliar_file(backup_file))
        print('备份: ' + current_file)
        shutil.move(current_file, backup_file)
    print('备份结束')

def job_print_duplicate_files():
    dst_folder = ss_dst_folder()
    dst_files = ss_all_level_items(dst_folder)
    info_dict = {}
    name_dict = {}
    for file in dst_files:
        md5 = ss_file_md5(file)
        size = str(os.path.getsize(file))
        info_key = md5 + '_' + size
        name_key = os.path.basename(file)
        
        if info_key in info_dict:
            l = info_dict[info_key]
            l.append(file)
        else:
            l = [file]
            info_dict[info_key] = l

        if name_key in name_dict:
            l = name_dict[name_key]
            l.append(file)
        else:
            l = [file]
            name_dict[name_key] = l

    for l in name_dict.values():
        if len(l) > 1:
            print('以下文件命名重复:')
            for file in l:
                print('' + file)

    print('')
    
    for l in info_dict.values():
        if len(l) > 1:
            print('以下文件可能重复:')
            for file in l:
                print('' + file)

def main():
    print('\nstart')

    # 打印上下文信息
    src_files = ss_all_level_items(ss_src_folder())
    dst_files = ss_all_level_items(ss_dst_folder())
    print('初始文件数: ' + str(len(src_files)))
    print('目录文件数: ' + str(len(dst_files)))

    # 拷贝初始目录中的所有文件到目标目录
    print('')
    job_copy_files()

    # 备份目标目录中的冗余文件
    print('')
    job_backup_redundant_files()

    # 打印目标目录中的重复文件
    print('')
    job_print_duplicate_files()

    print('\nfinish\n')

if __name__ == "__main__":
    main()