#!/bin/bash

pip install git+https://github.com/pixelogik/NearPy
pip install joblib
wget http://www.cs.cmu.edu/afs/cs/project/theo-11/www/naive-bayes/20_newsgroups.tar.gz
tar zxvf 20_newsgroups.tar.gz
rm 20_newsgroups.tar.gz

function get_text {
    grep -vP "[A-Z][a-z-]+: " |\
        sed "s/^>//;s/[^A-Za-z]/ /g;s/\s\s*/ /g;s/^ //;s/ \$//;/^$/d" |\
        tr ' ' '\n' | tr '[:upper:]' '[:lower:]' | perl porter.pl
}

echo Gathering the overall word frequencies
for FILE in $(find . -regex '.*/[0-9]+'); do
    cat $FILE | get_text   
done | sort | uniq -c | sort -rn | sed -e "s/  *//" | cut -f2 -d" " |\
    grep -vP "$(sed -e 's/^/(^/;s/$/$)/' stop_words.txt | tr '\n' '|' | sed -e 's/|$//')\$" |\
    head -n 4000 > feature_words.txt
#echo done

echo Extracting lists of frequent words
rm newsgroup.data
for CATEGORY in $(find 20_newsgroups/ -mindepth 1 -type d); do
    echo category: $CATEGORY
    LABEL=$(echo $CATEGORY | sed -e "s@/\$@@;s@.*/@@")
    for FILE in $(find $CATEGORY -regex ".*/[0-9]+"); do
        cat $FILE | get_text | sort |\
        diff - stop_words.txt | grep "<" | sed -e "s/< //" |\
        uniq -c | sed -e "s/  *//" |\
        perl join.pl | sed -e "s@\$@$LABEL,$FILE\n@" >> newsgroup.data.tmp
    done
done

sort -R newsgroup.data.tmp > newsgroup.data
rm newsgroup.data.tmp

python pickle_newsdata.py

