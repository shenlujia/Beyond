#!/bin/sh  sh framework_size.sh .
package_size(){
    app_size=0
    for framework in $(ls | grep framework); do
			cd $framework
        lib_file=${framework%%.*}
			fsize=$(xcrun size -m $lib_file  | 
					sed -n '/Section (/p
							/__debug/d' |
						awk -F":" '{total+= $2} END {print total}')

        m_bytes=$(echo "$fsize/1024/1024" | bc -l)
        echo $framework " : " $m_bytes              
        app_size=$((app_size+fsize))
        cd ..
    done

    app_size=$(echo "$app_size/1024/1024" | bc -l)
    printf "total: %s\n" $app_size
}

main(){
    if  [ $# -ne 1 ]; then
			echo "Usage: fk_size.sh path"
			return 1
		fi	

		pushd . >/dev/null
		cd $1
    package_size | sort -t ":" -k2 -r
    popd >dev/null
}

main "$@"
