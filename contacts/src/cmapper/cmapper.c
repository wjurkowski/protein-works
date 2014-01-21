#include "cmapper.h"

char* ext(char* path, char* extension)
{
	char* file = basename(path);
	char* temp = malloc((strlen(file) + strlen(extension) + 1) * sizeof(char));
	sprintf(temp, "%s%s", file, extension);
	return(temp);
}

int main(int argc, char** argv)
{
	if(argc < 5)
	{
		fprintf(stdout, "Too few parameters specified.\nSyntax: %s <receptor file> <matrix radius> <contact range> <ligand 1 file> [<ligand 2 file> ... <ligand n file>],\n\n", argv[0]);
		fprintf(stdout, "<receptor file> is receptor PDB file making complexes with ligands specified later.\n");
		fprintf(stdout, "<matrix size> describes radius of sphere (in Angstroms)\n\taround ligand in which lays residues that can have contact with ligand.\n\tUse 0 to match whole receptor.\n");
		fprintf(stdout, "<contact range> describes how close (in Angstroms)\n\tshould atoms of ligand and receptor be to make a contact.\n");
		fprintf(stdout, "<ligand 1> to <ligand n> are ligand PDB files making complex with receptor.\n");
	}
	else
	{
		fprintf(stdout, "Parsing receptor file:\t\t%s\n", argv[1]);
		FILE* proteinfile = fopen(argv[1], "r");
		if(proteinfile == NULL)
		{
			fprintf(stdout, "\tFatal: Can not open file.\n");
			return(-1);
		}	
		atom* protein = malloc(sizeof(atom));
		unsigned int ligok = 0;
		long result = get_protein(protein, proteinfile);
		fclose(proteinfile);
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
				fprintf(stdout, "\tFatal: less than 78 characters in line %ld.\n", result);
				return(-1);
			}		
		}
		ligand* ligands;	
		int file = 4;
		FILE* ligandfile = NULL;
		while((ligok == 0) && (file < argc))
		{
			fprintf(stdout, "Parsing ligand file [%d/%d]:\t%s\n", file - 3, argc - 4, argv[file]);
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
							fprintf(stdout, "\tError: less than 78 characters in line %ld.\n", result);
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
			fprintf(stdout, "Parsing ligand file [%d/%d]:\t%s\n", file - 3, argc - 4, argv[file]);
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
							fprintf(stdout, "\tError: less than 78 characters in line %ld.\n", result);
							free(lign);
				}
			}
			file++;
		}
		find_near_calpha(ligands, protein, atof(argv[2]));
		find_contacts(ligands, protein, atof(argv[3]));
		protein_result(ligands, ligok, argv[1], atof(argv[2]), atof(argv[3]));
		ligc = ligands;
		while(ligc != NULL)
		{
			ligand_result(ligc);
			ligc = ligc->next;
		}
		return(ligok);
	}
	return(-1);
}
