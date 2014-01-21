#include "cnative.h"

unsigned long longest_name_length(ligand* native, ligand* ligands)
{
	unsigned long longest = strlen(basename(native->owner));
	unsigned long result;
	ligand* lig = ligands;
	
	while(lig != NULL)
	{
		if((result = strlen(basename(lig->owner))) > longest) longest = result;
		lig = lig->next;
	}
	return(longest);
}

unsigned long longest_atom_char(ligand* native, ligand* ligands)
{
	unsigned long longest = 0;
	unsigned long result;
	
	atom* atm = native->atoms;	
	char* temp = malloc(LINELEN * sizeof(char) + 1);
	
	while(atm != NULL)
	{
		memset(temp, 0, LINELEN);
		sprintf(temp, "%ld", atm->number);
		if((result = strlen(atm->element)) < strlen(temp)) result = strlen(temp);
		if(result > longest) longest = result;
		atm = atm->next;
	}
	
	ligand* lig = ligands;
	while(lig != NULL)
	{
		atm = lig->atoms;
		while(atm != NULL)
		{
			memset(temp, 0, LINELEN);
			sprintf(temp, "%ld", atm->number);
			if((result = strlen(atm->element)) < strlen(temp)) result = strlen(temp);
			if(result > longest) longest = result;
			atm = atm->next;
		}
		lig = lig->next;
	}
	return(longest);
}

void print_spaces(unsigned long number, FILE* file)
{
	unsigned long i = 0;
	while(i != number)
	{
		fprintf(file, " ");
		i++;
	}
}

unsigned long* output(ligand* native, ligand* ligands, FILE* file)
{
	unsigned long longest_name = longest_name_length(native, ligands);
	unsigned long longest_char = longest_atom_char(native, ligands);
	char* temp = malloc(LINELEN * sizeof(char) + 1);
	ligand* lig = native;
	atom* atm = native->atoms;
	contact* cntct;
	
	print_spaces(longest_name + 1, file);
	fprintf(file, "| ");
	while(atm != NULL)
	{
		memset(temp, 0, LINELEN);
		sprintf(temp, "%ld", atm->number);
		fprintf(file, "%ld ", atm->number);
		print_spaces(longest_char - strlen(temp), file);
		atm = atm->next;
	}
	memset(temp, 0, LINELEN);
	fprintf(file, "\n%s", basename(native->owner));
	print_spaces(longest_name - strlen(basename(native->owner)), file);
	fprintf(file, " | ");
	
	atm = native->atoms;
	while(atm != NULL)
	{
		memset(temp, 0, LINELEN);
		sprintf(temp, "%s", atm->element);
		fprintf(file, "%s ", atm->element);
		print_spaces(longest_char - strlen(temp), file);
		atm = atm->next;
	}
	fprintf(file, "\n");
	print_spaces(longest_name + 1, file);
	fprintf(file, "| ");
	
	atm = native->atoms;
	while(atm != NULL)
	{
		memset(temp, 0, LINELEN);
		sprintf(temp, "%ld", atm->nocontacts);
		fprintf(file, "%ld ", atm->nocontacts);
		print_spaces(longest_char - strlen(temp), file);
		atm = atm->next;
	}
	double pos = ftell(file) / 3.0 - 1;
	int i;
	fprintf(file, "\n");
	for(i = 0; i < pos; i++) fprintf(file, "-");
	fprintf(file, "\n");
	
	lig = ligands;
	i = 0;
	while(lig != NULL)
	{
		i++;
		lig = lig->next;
	}
	unsigned long* array = malloc(i * sizeof(long));
		
	lig = ligands;
	i = 0;
	atom* atmn;
	atom* atmc;
	contact* cntctl;
	unsigned long result;
	while(lig != NULL)
	{
		array[i] = 0;
		memset(temp, 0, LINELEN);
		fprintf(file, "%s", basename(lig->owner));
		print_spaces(longest_name - strlen(basename(lig->owner)), file);
		fprintf(file, " | ");
		
		atmn = native->atoms;
		while(atmn != NULL)
		{
			atmc = lig->atoms;
			while(atmc != NULL)
			{
				if((strcmp(atmn->element, atmc->element) == 0) && (atmn->number == atmc->number))
				{
					cntct = atmn->contacts;
					result = 0;
					while(cntct != NULL)
					{
						cntctl = atmc->contacts;
						while(cntctl != NULL)
						{
							if((strcmp(cntct->resnum, cntctl->resnum) == 0) && (strcmp(cntct->resname, cntctl->resname) == 0))
							{
								result++;
								break;
							}
							else cntctl = cntctl->next;
						}
						cntct = cntct->next;
					}
					array[i] += result;
					memset(temp, 0, LINELEN);
					sprintf(temp, "%ld", result);
					fprintf(file, "%ld ", result);
					print_spaces(longest_char - strlen(temp), file);
					break;
				}
				else atmc = atmc->next;			
			}
			if(atmc == NULL)
			{
				fprintf(file, "X");
				print_spaces(longest_char, file);
			}	
			atmn = atmn->next;
		}
		lig = lig->next;
		i++;
		fprintf(file, "\n");
	}
	return(array);
}
