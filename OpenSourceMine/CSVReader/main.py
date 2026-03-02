import pandas as pd

def sort_numbers():
    numbers = []
    with open('1.txt', 'r') as file:
        for line in file:
            line = line.strip()
            if line.isdigit():
                numbers.append(int(line))

    numbers.sort()

    new_numbers = [f'"{num}"' for num in numbers]
    result = ','.join(new_numbers)

    with open('numbers_to_sorted_string.txt', 'w') as output_file:
        output_file.write(result)

def extract_ids():
    file_path = '1.csv'
    try:
        data = pd.read_csv(file_path)
        if 'ID' in data.columns:
            id_array = data['ID'].tolist()
            id_array.sort()
            string_array = [f'"{item}"' for item in id_array]
            result = ','.join(string_array)
            with open('csv_custom_colume_to_sorted_string.txt', 'w') as output_file:
                output_file.write(result)
        else:
            print("CSV文件中没有找到 'ID' 列")
    except FileNotFoundError:
        print(f"没有找到文件 {file_path}")


if __name__ == "__main__":
    # sort_numbers()
    extract_ids()
