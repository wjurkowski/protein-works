all:
	gcc -Wall -lm -o ./cmapper ./cmapper-src/cmapper.c ./cmapper-src/common.c ./cmapper-src/ligand.c ./cmapper-src/protein.c ./cmapper-src/results.c
	gcc -Wall -o ./cnative ./cnative-src/cnative.c ./cnative-src/parse.c ./cnative-src/output.c
clean:
	rm -f ./cmapper ./cnative
