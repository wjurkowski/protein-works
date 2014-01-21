#include "cmapper.h"

void ligand_result(ligand* lig)
{
	residue* res;
	atom* atm;
	contact* cntct;
	unsigned short int counter;

	char* temp = ext(lig->owner, ".out");
	fprintf(stdout, "Writing summary for ligand:\t%s\n", temp);
	FILE* file = fopen(temp, "w");
	if(file == NULL) fprintf(stdout, "\tError: can not open file for writing.\n");
	else
	{
		atm = lig->atoms;
		while(atm != NULL)
		{
			if(atm->nocontacts > 0)
			{
				/*fprintf(file, "(%ld,%s,%ld,%s,%s):", atm->resnum,atm->resname,atm->number, atm->element, atm->name);*/
				fprintf(file, "(%ld,%s,%ld,%s):", atm->resnum,atm->resname,atm->number, atm->name);
				cntct = atm->contacts;
				while(cntct != NULL)
				{
					/*fprintf(file, "(%ld,%s,%ld,%s,%s,%hd)", cntct->resnum, cntct->resname, cntct->number, cntct->element, cntct->name, cntct->hits);*/
					fprintf(file, "(%ld,%s,%ld,%s,%hd)", cntct->resnum, cntct->resname, cntct->number, cntct->name, cntct->hits);
					cntct = cntct->next;
					if(cntct != NULL) fprintf(file, ";"); else fprintf(file, "\n");
				}
				counter++;
			}
			atm = atm->next;
		}
		res = lig->residues;
		counter = 1;
		fclose(file);
	}
}

void protein_result(ligand* lig, unsigned int noligands, char* receptor, double radius, double range)
{
	char* temp = ext(receptor, ".rec.out");
	fprintf(stdout, "Writing brief contact summary:\t%s\n", temp);
	FILE* file = fopen(temp, "w");
	if(file == NULL) fprintf(stdout, "\tError: can not open file for writing.\n");
	else
	{
		ligand* ligc = lig;

		fprintf(file, "RECEPTOR:\t\t%s\n", ext(receptor, ""));
		fprintf(file, "NO. LIGANDS:\t\t%d\n", noligands);
		fprintf(file, "MATRIX RADIUS:\t\t%f\n", radius);
		fprintf(file, "CONTACT RANGE:\t\t%f\n\n", range);

		atom* atm;
		while(ligc != NULL)
		{
			unsigned long counter;
			unsigned long counter2;
			counter = 0;
			counter2 = 0;
			atm = ligc->atoms;

			while(atm != NULL)
			{
				counter += atm->nocontacts;
				if(atm->nocontacts > 0) counter2++;
				atm = atm->next;
			}
			fprintf(file, "LIGAND: %ld\t\t\t%s\n\tCONTACTS WITH RESIDUES:\t%ld\n\tCONTACTS WITH ATOMS:\t%ld\n", ligc->number, ext(ligc->owner, ""), counter2, counter);
			ligc = ligc->next;
		}
		fclose(file);
	}
}
