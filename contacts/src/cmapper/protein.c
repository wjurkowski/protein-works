#include "cmapper.h"

void find_near_calpha(ligand* lig, atom* atm, double radius)
{
	atom* atmc = atm;
	ligand* ligc;

	residue* resc;
	residue* resn;
	while(atmc != NULL)
	{
		ligc = lig;
		if(strcmp(atmc->name, "CA") == 0)
		while(ligc != NULL)
		{
			if(is_near_ligand(ligc, atmc, radius))
			{
				resn = malloc(sizeof(residue));
				resn->resnum = atmc->resnum;
				resn->resname = malloc(sizeof(atmc->resname));
				strcpy(resn->resname, atmc->resname);
				resn->next = NULL;
				if(ligc->residues == NULL) ligc->residues = resn;
				else
				{
					resc = ligc->residues;
					while(resc->next != NULL) resc = resc->next;
					resc->next = resn;
				}
				ligc->noresidues++;
			}
			ligc = ligc->next;
		}
		atmc = atmc->next;
	}
}

unsigned short int is_on_residue_list(ligand* lig, atom* atm)
{
	residue* res = lig->residues;
	while(res != NULL) if((res->resnum == atm->resnum) && (strcmp(res->resname, atm->resname) == 0)) return(1); else res = res->next;
	return(0);
}

long get_protein(atom* atm, FILE* file)
{
	char* line = malloc(LINELEN * sizeof(char) + 1);
	long result, linenum;
	atom* atmc = atm;
	atom* atmn;

	if((result = find_atom_section(file)) == -1) return(-1);
	else linenum = result + 1;
	fgets(line, LINELEN, file);
	if((result = get_atom(atm, line)) == 2) return(linenum);
	while(fgets(line, LINELEN, file) != NULL)
	{
		linenum++;
		atmn = malloc(sizeof(atom));
		if((result = get_atom(atmn, line)) == 2) return(linenum);
		else if(result == 0)
		{
			atmc->next = atmn;
			atmc = atmn;
		}
	}
	return(0);
}

void find_contacts(ligand* lig, atom* atm, double range)
{
	ligand* ligc = lig;
	atom* atmc;
	atom* atmn;
	contact* cntctc;
	contact* cntctn;

	while(ligc != NULL)
	{
		atmc = ligc->atoms;
		
		while(atmc != NULL)
		{
			cntctc = NULL;
			atmn = atm;
			while(atmn != NULL)
			{
				if((is_on_residue_list(ligc, atmn)) && (distance(atmc, atmn) <= range))
				{
					if(cntctc != NULL) while(cntctc->next != NULL) cntctc = cntctc->next;
					if((cntctc == NULL) || ((cntctc->resnum != atmn->resnum) && (strcmp(cntctc->resname, atmn->resname) != 0)))
					{
						cntctn = malloc(sizeof(contact));
						cntctn->resnum = atmn->resnum;
						cntctn->number= atmn->number;
						cntctn->element=atmn->element;
						cntctn->name=atmn->name;
						cntctn->hits = 1;
						cntctn->resname = malloc((strlen(atmn->resname) + 1) * sizeof(char));
						strcpy(cntctn->resname, atmn->resname);
						cntctn->next = NULL;
						if(cntctc == NULL) atmc->contacts = cntctn;
						else cntctc->next = cntctn;
					}
					else cntctc->hits++;
					cntctc = cntctn;
					atmc->nocontacts++;
				}
				atmn = atmn->next;
			}
			atmc = atmc->next;
		}
		ligc = ligc->next;
	}
}
