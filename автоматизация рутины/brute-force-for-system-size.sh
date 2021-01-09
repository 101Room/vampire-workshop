#!/bin/sh

# Этот скрипт для перебора размера системы, построения графика для каждого моделирования
# (запрашивает у пользователя какие величины строить). Ещё скрипт считает сколько времени ушло
# на каждое моделирование и выводит график зависимости времени моделирования системы
# от её размера. Считает и суммарное время на моделирование. Эти подсчёты времени могут быть
# полезны, для дальнейшего понимания какой расчёт сколько времени займёт.

# строка с !/bin/sh нужна, её нельзя трогать! (хоть она и после символа коммента)
# скрипт нужно запускать в той же папке, где входные данные (файл input)
# скрипт прерывается с помощью ctrl + C

LIMITCOUNTER=16 # верхний предел счётчика, вставьте свой

COUNTER=1 # начальное значение счётчика, вставьте своё

SPENTTIME=0 # начальное значение счётчика времени, которое уйдёт на моделирование всей серии

echo "#размер системы, нм	время на моделирование, мин" > time-spent-for-simulation # в файл
# time-spent-for-simulation пишем заголовок, далее в нём будет писаться сколько времени ушло
# на моделирование системы в зависимости от размера

echo "Ваши выходные данные на этот раз:"
grep output: input | cut -d: -f2 # извлекаем из вашего входного файла что вы там задали
# как выходные данные, чтобы вы увидели их и верно указали номера нужных для построения столбцов

echo -e "\nПомните, что \"magnetisation\" состоит из 4 колонок"
echo -en "Введите \033[1;36mномер колонки\033[0m для x-оси и \033[1;36mподпись для неё\033[0m:"
read XAXIS XLABEL # читает ваш ввод
echo -en "Введите \033[1;36mномер колонки\033[0m для y-оси и \033[1;36mподпись для неё\033[0m:"
read YAXIS YLABEL

while [ $COUNTER -lt $LIMITCOUNTER ] ; do # цикл, который будет менять размер системы

	sed -i '/dimensions:system-size/s/[0-9]\{1,3\}/'$COUNTER'/g' input # регулярное выражение
    # для поиска размера системы в input и его смены
    
	TIMESTART=$(date +%s) # начинаем отсчёт времени на моделирование системы этого размера
    
	vampire-serial # запускаем моделирование, тут НЕ паралельный запуск, исправьте, если надо
    
	TIMEFINISH=$(date +%s) # завершаем отсчёт времени на моделирование системы этого размера
    
	echo "$COUNTER	$(((TIMEFINISH-TIMESTART)/60))" >> time-spent-for-simulation # выводим
    # это время в файл time-spent-for-simulation
    
	let SPENTTIME+=$(((TIMEFINISH-TIMESTART)/60)) # добавляем потраченное время в переменную,
    # где фиксируется время на всю серию моделирований
  
	MAT=$(grep *.mat input | cut -d= -f2) # считываем название материала из входного файла
  
	SIZEX=$(grep dimensions:system-size-x input | cut -d= -f2) # считываем размеры системы
    # из входного файла
	SIZEY=$(grep dimensions:system-size-y input | cut -d= -f2)
	SIZEZ=$(grep dimensions:system-size-z input | cut -d= -f2)
  
	INTEGRATOR=$(grep sim:integrator input | cut -d= -f2) # считываем метод моделирования
    # из входного файла
  
  # запускаем программу для построения графика, где считанные из input данные добавляются
  # как подписи, чтобы не запутаться потом и не забыть
	gnuplot << EOF
		set terminal jpeg
		set output "$COUNTER.jpg"
		set title "material:$MAT; size$SIZEX x$SIZEY x$SIZEZ; integrator$INTEGRATOR"
		set xlabel "$XLABEL"
		set ylabel "$YLABEL"
		plot "output" using $XAXIS:$YAXIS notitle
EOF

mv output $COUNTER # переименовываем output, добавляя в его имя размер системы, так он сохранится

	let COUNTER+=1 # увеличиваем счётчик на 1

done

# строим график о потраченном времени на каждую симуляцию
gnuplot << EOF
	set terminal jpeg
	set output "time-spent-for-simulation.jpg"
	set title "time spent for each simulation, total spent (sum) $SPENTTIME min"
	set xlabel "system size, nm"
	set ylabel "time, min"
	plot "time-spent-for-simulation" using 1:2 pt 6 notitle
EOF

echo "This brute-force cycle took $SPENTTIME minutes" # выводим суммарное время на моделирование
