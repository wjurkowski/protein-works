#include "cmapper.h"

void find_center(ligand* lig)
{
	atom* atmc = lig->atoms;
	atom* atmn;
	atom* max1;
	atom* max2;
	double distmax = 0.0;
	double distcur = 0.0;

	if(atmc->next == NULL)
	{
		max1 = lig->atoms;
		max2 = lig->atoms;
	}
	else while(atmc != NULL)
	{
		atmn = atmc->next;
		while(atmn != NULL)
		{
			if((distcur = distance(atmc, atmn)) > distmax)
			{
				distmax = distcur;
				max1 = atmc;
				max2 = atmn;
			}
			atmn = atmn->next;
		}
		atmc = atmc->next;
	}
	
	lig->cx = (max1->x + max2->x) / 2.0;
	lig->cy = (max1->y + max2->y) / 2.0;
	lig->cz = (max1->z + max2->z) / 2.0;
	lig->radius = distmax / 2.0;
}

long get_ligand(ligand* lig, unsigned long number, char* owner, FILE* file)
{
	char* line = malloc((LINELEN + 1) * sizeof(char));
	unsigned long noatoms = 1;
	long result, linenum;
	
	if((result = find_atom_section(file)) == -1) return(-1);
	else linenum = result + 1;

	atom* atmr = malloc(sizeof(atom));
	fgets(line, LINELEN, file);
	if(get_atom(atmr, line) == 2) return(linenum);

	atom* atmc = atmr;
	atom* atmn = NULL;
	while(fgets(line, LINELEN, file) != NULL)
	{
		linenum++;
		atmn = malloc(sizeof(atom)); 
		if((result = get_atom(atmn, line)) == 2) return(linenum);
		else if(result == 0)
		{
			atmc->next = atmn;
			atmc = atmc->next;
			noatoms++;
		}
		else free(atmn);
	}
	lig->number = number;
	lig->noatoms = noatoms;
	lig->name = malloc((strlen(atmr->resname) + 1) * sizeof(char));
	strcpy(lig->name, atmr->resname);
	lig->owner = malloc((strlen(owner) + 1) * sizeof(char));
	strcpy(lig->owner, owner);
	lig->atoms = atmr;
	lig->residues = NULL;
	lig->noresidues = 0;

	find_center(lig);

	return(0);
}
