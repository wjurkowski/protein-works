#include <libgen.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/wait.h>

#define LINELEN 1024

struct contact
{
	unsigned long hits;

	char* resnum;
	char* resname;

	struct contact* next;
};

typedef struct contact contact;

struct atom
{
	unsigned long number;
	unsigned long nocontacts;
	
	char* element;

	contact* contacts;
	
	struct atom* next;
};

typedef struct atom atom;

struct ligand
{
	unsigned long number;

	char* owner;
	atom* atoms;

	struct ligand* next;
};

typedef struct ligand ligand;

long find_atom_section(FILE*);
long get_contact(contact*, char*, unsigned int);
unsigned short int get_atom(atom*, char*);
long get_ligand(ligand*, unsigned long, char*, FILE*);
char* ext(char*, char*);
unsigned long longest_name_length(ligand*, ligand*);
unsigned long longest_atom_char(ligand*, ligand*);
void print_spaces(unsigned long, FILE*);
unsigned long* output(ligand*, ligand*, FILE*);
