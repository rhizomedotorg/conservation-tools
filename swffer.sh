#!/bin/bash

# automated SWF crawler
# written by Alexander Duryee 03/2013
# requires bash, swfmill, and some patience

# initialize arrays/variables
DONE=('derp')
FIN=0
DON=0

while [ $FIN -ne 1 ]
do
	# populate the SWFs to process
	SWFS=(`find . | grep -i '\.swf'`)
	FIN=1
	for x in ${SWFS[*]}
	do
		# check if a SWF was already processed
		# if so, don't enter the processing statement
		for y in ${DONE[@]}
		do
			if [[ $x == $y ]]
			then
				DON=1
			fi
		done
		if [[ $DON -ne 1 ]] 
		then
			echo "Operating on ${x}"
			
			# build the paths
			filename=`basename $x`
			dir=`echo $x | sed s/$filename//g`
			path=`echo $x | sed s/$filename//g | sed s#^.#http:/#`
			
			# scan SWF for URLs and format into something nice
			NEW=(`swfmill swf2xml $x | grep '\<GetURL' | sed s/^.*\<// | tr '\ ' '#'`)
			
			# process each found URL
			for element in ${NEW[*]}
			do
				url=`echo ${element} | cut -d \" -f 2`
				
				# special case - GetURL2
				# these are URLs generated on-the-fly and not machine-readable
				# you'll want to look at these manually
				if [[ "${element}" =~ GetURL2 ]]
				then
					echo "GetURL2 found at ${dir}${filename} - examine manually!"
				
				# if our new SWF doesn't exist locally, grab it
				elif [[ ! -a ${dir}${url} ]]
				then
					# check for hardlinks and don't process those
					if [[ "${url}" =~ http ]]
					then
						echo "Hardlink found at ${url} - adjust manually!"
					
					# if the URL isn't a mailto or Flash command, get it
					elif [[ -n "${url}" ]] && [[ ! "${url}" =~ mailto ]] && [[ ! "${url}" =~ FSCommand ]]
					then
						echo "Good URL found at ${dir}${url}! Downloading..."
						wget -rkp -l inf -a swflog.txt ${path}${url}	
						
						# check to stop infinite loops from 404'd links
						if [[ -a ${dir}${url} ]]
						then
							FIN=0
						fi
					fi
				fi
			done
			
			# push the now-processed SWF into the DONE array
			DONE+=(${x})
		fi
		# reset the processed check for another round
		DON=0
	done
done

# end of script stats
echo "Finished processing links under ${DONE[1]}"
echo "Processed ${#DONE[@]} files"
