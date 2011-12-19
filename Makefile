all: colocations-hs colocations-cpp

prof: colocations-hs-prof colocations-cpp-prof

colocations-hs: Colocations.hs
	ghc -O2 -Wall Colocations.hs -o colocations-hs

colocations-cpp: Colocations.cpp
	g++ -O2 -Wall -std=c++0x -Iboost Colocations.cpp -o colocations-cpp

colocations-hs-prof: Colocations.hs
	ghc -prof -auto-all -rtsopts Colocations.hs -o colocations-hs-prof

colocations-cpp-prof: Colocations.cpp
	g++ -Wall -pg -std=c++0x -Iboost Colocations.cpp -o colocations-cpp-prof


all-plots: plots/time_memory.gnuplot
	cd plots; cat time_memory.gnuplot | gnuplot

clean:
	rm -rf colocations-hs* colocations-cpp* *.hi *.o plots/time.png plots/memory.png \
           plots/time.eps plots/memory.eps plots/ratios.png
