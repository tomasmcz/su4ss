#!/bin/bash

# wget http://www.cs.cmu.edu/afs/cs/project/theo-11/www/naive-bayes/20_newsgroups.tar.gz
# tar zxvf 20_newsgroups.tar.gz
# rm 20_newsgroups.tar.gz

function get_text {
    grep -vP "[A-Z][a-z-]+: " |\
        sed "s/^>//;s/[^A-Za-z]/ /g;s/\s\s*/ /g;s/^ //;s/ \$//;/^$/d" |\
        tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | perl porter.pl
}

for FILE in $(find . -regex '.*/[0-9]+'); do
    cat $FILE | get_text   
done | sort | uniq -c | sort -rn | sed -e "s/  *//" | cut -f2 -d" "  > freq_list.tmp

for I in 500 1000 2000 3000 4000; do
    head -n $I freq_list.tmp | sort | diff - stop_words.txt | grep "<" |\
        sed -e "s/< //" > feature-words-$I.txt
done
rm freq_list.tmp

for CATEGORY in $(find 20_newsgroups/ -mindepth 1 -type d); do
    LABEL=$(echo $CATEGORY | sed -e "s@/\$@@;s@.*/@@")
    for FILE in $(find $CATEGORY -regex ".*/[0-9]+"); do
        cat $FILE | get_text |\
        diff - stop_words.txt | grep "<" | sed -e "s/< //" > tmp.txt
        for I in 500 1000 2000 3000 4000; do
            perl join.pl $I < tmp.txt | sed -e "s@\$@$LABEL\n@" >> newsgroup-$I.tmp
        done
    done
done

for I in 500 1000 2000 3000 4000; do
    sort -R newsgroup-$I.tmp > newsgroup-$I.data
    rm newsgroup-$I.tmp
done
