#include "cnative.h"

long find_atom_section(FILE* file)
{
	char* line = malloc(LINELEN * sizeof(char));
	unsigned long number = 0;

	while((fgets(line, LINELEN, file) != NULL) && (strncmp(line, "ATOM", 4) != 0)) number++;
	if(strncmp(line, "ATOM", 4) == 0)
	{
		fseek(file, -strlen(line), SEEK_CUR);
		return(number);
	}
	else return(-1);
	
}

long get_contact(contact* cntct, char* line, unsigned int position)
{
	unsigned int pos = position;
	
	if(pos + 6 >= strlen(line)) return(-1);
	else pos++;
	
	char* temp = malloc(strlen(line) * sizeof(char) + 1);
	memset(temp, 0, strlen(line));

	while(line[pos] != ',')
	{
		if(pos == strlen(line)) return(-1);
		if((line[pos] == '(') || (line[pos] == ')') || (line[pos] == ':')) return(-1);
		else temp[strlen(temp)] = line[pos];
		pos++;
	}
	cntct->resnum = malloc(strlen(temp) * sizeof(char) + 1);
	strcpy(cntct->resnum, temp);
	
	pos++;
	memset(temp, 0, strlen(line));
	while(line[pos] != ',')
	{
		if(pos == strlen(line)) return(-1);
		if((line[pos] == '(') || (line[pos] == ')') || (line[pos] == ':')) return(-1);
		else temp[strlen(temp)] = line[pos];
		pos++;
	}
	cntct->resname = malloc(strlen(temp) * sizeof(char) + 1);
	strcpy(cntct->resname, temp);

	pos++;
	memset(temp, 0, strlen(line));
	while(line[pos] != ')')
	{
		if(pos == strlen(line)) return(-1);
		if((line[pos] == '(') || (line[pos] == ',') || (line[pos] == ':')) return(-1);
		else temp[strlen(temp)] = line[pos];
		pos++;
	}
	cntct->hits = atoi(temp);
	return(pos);
}

unsigned short int get_atom(atom* atm, char* line)
{
	if(strncmp(line, "ATOM", 4) != 0) return(1);
	if(strlen(line) < 17) return(1);
	if(line[4] != '(') return(1);
	
	char* temp = malloc(strlen(line) * sizeof(char) + 1);
	memset(temp, 0, strlen(line));
	
	long i = 5;
	long result;
	
	while(line[i] != ',')
	{
		if(i == strlen(line)) return(1);
		if((line[i] == '(') || (line[i] == ')') || (line[i] == ':')) return(1);
		else temp[strlen(temp)] = line[i];
		i++;
	}
	atm->number = atof(temp);
	atm->nocontacts = 0;
	i++;
	memset(temp, 0, strlen(line));
	while(line[i] != ')')
	{
		if(i == strlen(line)) return(1);
		if((line[i] == '(') || (line[i] == ',') || (line[i] == ':')) return(1);
		else temp[strlen(temp)] = line[i];
		i++;
	}
	atm->element = malloc(strlen(temp) * sizeof(char) + 1);
	strcpy(atm->element, temp);
		
	if(i++ + 1 >= strlen(line)) return(1);
	while((line[i] == ' ') || (line[i] == '\t')) i++;
	if(line[i] != ':') return(1); else i++;
	while((line[i] == ' ') || (line[i] == '\t')) i++;
	if(line[i] != '(') return(1);
	
	contact* cntctr = malloc(sizeof(contact));
	contact* cntctc = cntctr;
	contact* cntctn;
	
	if((result = get_contact(cntctr, line, i)) == -1) return(1);
	else
	{
		i = result + 1;
		atm->nocontacts++;
	}
	while(i < strlen(line) - 1)
	{
		if((line[i] == ' ') || (line[i] == '\t'))
		{
			i++;
			continue;
		}
		if(line[i] != ';') return(1);
		else 
		{
			i++;
			while((line[i] == ' ') || (line[i] == '\t')) i++;
			if(i + 6 >= strlen(line)) return(1);
			else if(line[i] != '(') return(1);
			cntctn = malloc(sizeof(contact));
			if((result = get_contact(cntctn, line, i)) == -1) return(1);
			else
			{
				i = result + 1;
				cntctc->next = cntctn;
				cntctc = cntctc->next;
				atm->nocontacts++;
			}
		}
	}
	atm->contacts = cntctr;
	
	return(0);
}	

long get_ligand(ligand* lig, unsigned long number, char* owner, FILE* file)
{
	char* line = malloc(LINELEN * sizeof(char));
	long result, linenum;
	
	if((result = find_atom_section(file)) == -1) return(-1);
	else linenum = result + 1;

	atom* atmr = malloc(sizeof(atom));
	fgets(line, LINELEN, file);
	if(get_atom(atmr, line) == 1) return(linenum);

	atom* atmc = atmr;
	atom* atmn = NULL;
	while(fgets(line, LINELEN, file) != NULL)
	{
		linenum++;
		atmn = malloc(sizeof(atom)); 
		if((result = get_atom(atmn, line)) == 1) return(linenum);
		else if(result == 0)
		{
			atmc->next = atmn;
			atmc = atmc->next;
		}
		else free(atmn);
	}
	lig->number = number;
	lig->owner = malloc(strlen(owner) * sizeof(char) + 1);
	strcpy(lig->owner, owner);
	lig->atoms = atmr;

	return(0);
}
