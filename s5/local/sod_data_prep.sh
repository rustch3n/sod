#!/bin/bash
# Copyright 2016  Tsinghua University (Author: Dong Wang, Xuewei Zhang).  Apache 2.0.
#           2016  LeSpeech (Author: Xingyu Na)

#This script pepares the data directory for thchs30 recipe. 
#It reads the corpus and get wav.scp and transcriptions.

dir=$1
corpus_dir=$2
wavid=$3

cd $dir

echo "creating data/$wavid"
mkdir -p data/$wavid

#create wav.scp, utt2spk.scp, spk2utt.scp, text
(
  x=$wavid
  echo "cleaning data/$x"
  cd $dir/data/$x
  rm -rf wav.scp utt2spk spk2utt word.txt phone.txt text
  echo "preparing scps and text in data/$x"
  for nn in `find  $corpus_dir/*.wav | sort -u | xargs -i basename {} .wav`; do
      spkid=`echo $nn | awk -F"_" '{print "" $1}'`
      spk_char=`echo $spkid | sed 's/\([A-Z]\).*/\1/'`
      spk_num=`echo $spkid | sed 's/[A-Z]\([0-9]\)/\1/'`
      spkid=$(printf '%s%.2d' "$spk_char" "$spk_num")
      utt_num=`echo $nn | awk -F"_" '{print $2}'`
      uttid=$(printf '%s%.2d_%.3d' "$spk_char" "$spk_num" "$utt_num")
      echo $uttid $corpus_dir/$nn.wav >> wav.scp
      echo $uttid $spkid >> utt2spk
      echo $uttid `sed -n 1p $corpus_dir/$nn.wav.trn` >> word.txt
      echo $uttid `sed -n 3p $corpus_dir/$nn.wav.trn` >> phone.txt
  done 
  cp word.txt text
  sort wav.scp -o wav.scp
  sort utt2spk -o utt2spk
  sort text -o text
  sort phone.txt -o phone.txt

) || exit 1

#utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
#utils/utt2spk_to_spk2utt.pl data/dev/utt2spk > data/dev/spk2utt
utils/utt2spk_to_spk2utt.pl data/$wavid/utt2spk > data/$wavid/spk2utt

# echo "creating test_phone for phone decoding"
# (
  # rm -rf data/test_phone && cp -R data/test data/test_phone  || exit 1
  # cd data/test_phone && rm text &&  cp phone.txt text || exit 1
# )

