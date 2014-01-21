#include "cnative.h"

char* ext(char* path, char* extension)
{
	char* file = basename(path);
	char* temp = malloc((strlen(file) + strlen(extension) + 1) * sizeof(char));
	sprintf(temp, "%s%s", file, extension);
	return(temp);
}

int main(int argc, char** argv)
{
	if(argc < 3)
	{
		fprintf(stdout, "Too few parameters specified.\nSyntax: %s <native ligand file> <ligand 1 file> [<ligand 2 file> ... <ligand n file>],\n\n", argv[0]);
		fprintf(stdout, "<native ligand file> is ligand PDB file used as basis for comparition.\n");
		fprintf(stdout, "<ligand 1> to <ligand n> are ligand PDB files compared with native one.\n");
	}
	else
	{
		fprintf(stdout, "Parsing native contact file:\t%s\n", argv[1]);
		FILE* nativefile = fopen(argv[1], "r");
		if(nativefile == NULL)
		{
			fprintf(stdout, "\tFatal: Can not open file.\n");
			return(-1);
		}	
		ligand* native = malloc(sizeof(atom));
		unsigned int ligok = 0;
		long result = get_ligand(native, 0, argv[1], nativefile);
		fclose(nativefile);
		switch(result)
		{
			case -1:
				{
					fprintf(stdout, "\tFatal: not a PDB file or no ATOM section found.\n");
					return(-1);		
				}
			case 0:
				{
					fprintf(stdout, "\tSuccess.\n"); 
					break;
				}
			default:
			{
				fprintf(stdout, "\tFatal: error in line %ld.\n", result);
				return(-1);
			}		
		}
		ligand* ligands;
		int file = 2;
		FILE* ligandfile = NULL;
		while((ligok == 0) && (file < argc))
		{
			fprintf(stdout, "Parsing contact file [%d/%d]:\t%s\n", file - 1, argc - 2, argv[file]);
			ligandfile = fopen(argv[file], "r");
			if(ligandfile == NULL)
			{
				fprintf(stdout, "\tError: Can not open file.\n");
			}
			else
			{
				ligands = malloc(sizeof(ligand));
				result = get_ligand(ligands, 1, argv[file], ligandfile);
				fclose(ligandfile);
				switch(result)
				{
					case -1:
						{
							fprintf(stdout, "\tError: not a PDB file or no ATOM section found.\n");
							free(ligands);
							break;
						}
					case 0:
						{	
							fprintf(stdout, "\tSuccess.\n");
							ligok = 1;
							break;
						}
					default:
						{
							fprintf(stdout, "\tError: error in line %ld.\n", result);
							free(ligands);
						}
				}
			}
			file++;
		}
		if(ligok == 0)
		{
			fprintf(stdout, "No available ligands found.\n");
			return(0);
		}
		ligand* ligc = ligands;
		ligand* lign;
		while(file < argc)
		{
			fprintf(stdout, "Parsing contact file [%d/%d]:\t%s\n", file - 1, argc - 2, argv[file]);
			ligandfile = fopen(argv[file], "r");
			if(ligandfile == NULL) fprintf(stdout, "\tError: Can not open file.\n");
			else
			{
				lign = malloc(sizeof(ligand));
				result = get_ligand(lign, ligok + 1, argv[file], ligandfile);
				fclose(ligandfile);
				switch(result)
				{
					case -1:
						{
							fprintf(stdout, "\tError: not a PDB file or no ATOM section found.\n");
							free(lign);
							break;
						}
					case 0:
						{
							fprintf(stdout, "\tSuccess.\n");
							ligc->next = lign;
							ligc = lign;
							ligok++;
							break;
						}		
					default:
							fprintf(stdout, "\tError: error in line %ld.\n", result);
							free(lign);
				}
			}
			file++;
		}
		fprintf(stdout, "Writing comparition file:\t%s\n", ext(argv[1], ".log"));
		FILE* resultfile = fopen(ext(argv[1], ".log"), "w");
		unsigned long* results = output(native, ligands, resultfile);
		fclose(resultfile);
		fprintf(stdout, "Writing gnuplot data file:\t%s\n", ext(argv[1], ".dat"));
		resultfile = fopen(ext(argv[1], ".dat"), "w");
		for(result = 1; result < ligok + 1; result++) fprintf(resultfile, "%ld\t%ld\n", result, results[result - 1]);
		fclose(resultfile);
		fprintf(stdout, "Writing gnuplot commands file:\t%s\n", ext(argv[1], ".plot"));
		resultfile = fopen(ext(argv[1], ".plot"), "w");
		result = 0;
		atom* atm = native->atoms;
		while(atm != NULL)
		{
			result += atm->nocontacts;
			atm = atm->next;
		}
		fprintf(resultfile, "set terminal png\n");
		fprintf(resultfile, "set output \"%s\"\n", ext(argv[1], ".png"));
		fprintf(resultfile, "set title \"%s\"\n", basename(argv[1]));
		fprintf(resultfile, "set xrange [0.5:%d.5]\n", ligok);
		fprintf(resultfile, "set yrange [0:%ld]\n", result);
		fprintf(resultfile, "set xlabel \"ligands\"\n");
		fprintf(resultfile, "set ylabel \"matching residues\"\n");
		if(ligok != 1) fprintf(resultfile, "set boxwidth 0.5 relative\n");
		else fprintf(resultfile, "set boxwidth 0.4\n");
		fprintf(resultfile, "unset key\n");
		fprintf(resultfile, "plot \"%s\" w boxes fs solid 0.25\n", ext(argv[1], ".dat"));
		fclose(resultfile);
		fprintf(stdout, "Trying to plot file:\t\t%s\n", ext(argv[1], ".png"));
		execlp("gnuplot", "gnuplot", ext(argv[1], ".plot"), (char*)NULL);
		return(ligok);
	}
	return(-1);
}
