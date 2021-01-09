#!/bin/sh

# строка с !/bin/sh нужна, её нельзя трогать! (хоть она и после символа коммента)
# скрипт нужно запускать в той же папке, где входные данные (файл input)
# скрипт прерывается с помощью ctrl + C

read -p "Введите имя для файла картинки-графика: " IMAGENAME
read -p "Задайте подпись для графика: " TITLE

MAT=$(grep *.mat input | cut -d= -f2) # считываем название материала из входного файла

SIZEX=$(grep dimensions:system-size-x input | cut -d= -f2) # считываем размеры системы
# из входного файла
SIZEY=$(grep dimensions:system-size-y input | cut -d= -f2)
SIZEZ=$(grep dimensions:system-size-z input | cut -d= -f2)

INTEGRATOR=$(grep sim:integrator input | cut -d= -f2) # считываем метод моделирования
# из входного файла

echo -e "Вы ы курсе, что моделировали материал:$MAT? Остановите скрипт ctrl + C, если поняли, что ошиблись \n"

echo "Ваши выходные данные на этот раз:"
grep output: input | cut -d: -f2

echo -e "\nПомните, что \"magnetisation\" состоит из 4 колонок"
echo -en "Введите \033[1;36mномер колонки\033[0m для x-оси и \033[1;36mподпись для неё\033[0m:"
read XAXIS XLABEL
echo -en "Введите \033[1;36mномер колонки\033[0m для y-оси и \033[1;36mподпись для неё\033[0m:"
read YAXIS YLABEL

# запускаем программу для построения графика, где считанные из input данные добавляются
# как подписи, чтобы не запутаться потом и не забыть
gnuplot << EOF
  set terminal jpeg
  set output "$IMAGENAME.jpg"
  set title "\"$TITLE\"; material:$MAT; size$SIZEX x$SIZEY x$SIZEZ; integrator$INTEGRATOR"
  set xlabel "$XLABEL"
  set ylabel "$YLABEL"
  plot "output" using $XAXIS:$YAXIS notitle
EOF
