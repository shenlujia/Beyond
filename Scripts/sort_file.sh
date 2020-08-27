
echo
input=()
for x in ` awk '{print $1}' $1 ` 
{
  input+=($x)
}
echo "输入${#input[@]}个对象:"
echo ${input[@]}

echo
sorted_str=$(echo ${input[@]} | tr ' ' '\n' | sort -n)
sorted=(${sorted_str//,/ })
echo "排序后${#sorted[@]}个对象:"
echo ${sorted[@]}

echo
for i in ${sorted[@]}; do
  echo ${i} >> sort_file_out.txt
done

exit 0