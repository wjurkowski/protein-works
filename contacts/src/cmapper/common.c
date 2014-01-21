#include "cmapper.h"

unsigned short int get_atom(atom* atm, char* line)
{
	if(strncmp(line, "ATOM", 4) != 0) return(1);
	if(strlen(line) < LINELEN - 1) return(2);
	
	char* temp = malloc(10 * sizeof(char));
	unsigned int i;

	memset(temp, 0, LINELEN);
	for(i = 6; i < 11; i++) if(line[i] != ' ') temp[strlen(temp)] = line[i];
	atm->number = atol(temp);
/*fprintf(stdout, "dupa\n");*/
	
	memset(temp, 0, LINELEN);
	for(i = 22; i < 26; i++) if(line[i] != ' ') temp[strlen(temp)] = line[i];
	atm->resnum = atol(temp);

	memset(temp, 0, LINELEN);
	for(i = 30; i < 38; i++) if(line[i] != ' ') temp[strlen(temp)] = line[i];
	atm->x = atof(temp);

	memset(temp, 0, LINELEN);
	for(i = 38; i < 46; i++) if(line[i] != ' ') temp[strlen(temp)] = line[i];
	atm->y = atof(temp);

	memset(temp, 0, LINELEN);
	for(i = 46; i < 54; i++) if(line[i] != ' ') temp[strlen(temp)] = line[i];
	atm->z = atof(temp);

	memset(temp, 0, LINELEN);
	for(i = 12; i < 16; i++)
	{
	    if((line[i] == ' ') && (strlen(temp) == 0)) continue;
	    temp[strlen(temp)] = line[i];
	}
	for(i = strlen(temp) - 1; i >= 0; i--) if(temp[i] == ' ') temp[i] = 0; else break;
	atm->name = malloc((strlen(temp) + 1) * sizeof(char));
	strcpy(atm->name, temp);

	memset(temp, 0, LINELEN);
	for(i = 17; i < 20; i++)
	{
	    if((line[i] == ' ') && (strlen(temp) == 0)) continue;
	    temp[strlen(temp)] = line[i];
	}
	for(i = strlen(temp) - 1; i >= 0; i--) if(temp[i] == ' ') temp[i] = 0; else break;
	atm->resname = malloc((strlen(temp) + 1) * sizeof(char));
	strcpy(atm->resname, temp);
	
	/*memset(temp, 0, LINELEN);
	for(i = 76; i < 79; i++)
	{
	    if((line[i] == ' ') && (strlen(temp) == 0)) continue;
	    temp[strlen(temp)] = line[i];
	}
	for(i = strlen(temp) - 1; i >= 0; i--) if(temp[i] == ' ') temp[i] = 0; else break;  
	atm->element = malloc((strlen(temp) + 1) * sizeof(char));
	strcpy(atm->element, temp);*/
	
	atm->nocontacts = 0;
	atm->contacts = NULL;
	atm->next = NULL;

	return(0);
}

long find_atom_section(FILE* file)
{
	char* line = malloc((LINELEN + 1) * sizeof(char));
	unsigned long number = 0;

	while((fgets(line, LINELEN, file) != NULL) && (strncmp(line, "ATOM", 4) != 0)) number++;
	if(strncmp(line, "ATOM", 4) == 0)
	{
		fseek(file, -strlen(line), SEEK_CUR);
		return(number);
	}
	else
	{
		return(-1);
	}
}

double distance(atom* atm1, atom* atm2)
{
	return(sqrt(pow(atm1->x - atm2->x, 2.0) + pow(atm1->y - atm2->y, 2.0) + pow(atm1->z - atm2->z, 2.0)));
}

unsigned short int is_near_ligand(ligand* lig, atom* atm, double radius)
{
	return((radius == 0) || (sqrt(pow(lig->cx - atm->x, 2.0) + pow(lig->cy - atm->y, 2.0) + pow(lig->cz - atm->z, 2.0)) <= radius));
}
