all: colocations-hs colocations-cpp

colocations-hs: Colocations.hs
	ghc -O2 -Wall Colocations.hs -o colocations-hs

colocations-cpp: Colocations.cpp
	g++ -O2 -Wall -std=c++0x -Iboost Colocations.cpp -o colocations-cpp

all-plots: plots/time_memory.gnuplot
	cd plots; cat time_memory.gnuplot | gnuplot

clean:
	rm -rf colocations-hs colocations-cpp *.hi *.o plots/*.png plots/*.eps
