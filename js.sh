cfg=/exp/sbnd/app/users/yuhw/wct-cfg/cfg
#cfg=/home/yuhw/wc/larsoft925/src/wct/cfg
#cfg1=/home/yuhw/wc/sbnd/op/cfg

name=$2
name=${name%.*}

if [[ $1 == "json" || $1 == "all" ]]; then
jsonnet \
--ext-code DL=4.0 \
--ext-code DT=8.8 \
--ext-code lifetime=10.4 \
--ext-code driftSpeed=1.60563 \
--ext-str opflash0_input_label="opflashtpc0:" \
--ext-str opflash1_input_label="opflashtpc1:" \
--ext-str raw_input_label="daq:" \
-J $cfg \
${name}.jsonnet \
-o ${name}.json
fi

if [[ $1 == "pdf" || $1 == "all" ]]; then
    wirecell-pgraph dotify --jpath -1 --no-services --no-params ${name}.json ${name}.pdf
    #wirecell-pgraph dotify --no-services --jpath -1 ${name}.json ${name}.pdf
fi
