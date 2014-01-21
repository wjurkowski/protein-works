#!/usr/bin/python

import sys,re,os;
from urllib2 import urlopen;

# sys.path.append('/afs/pdc.kth.se/home/a/aronh/1vol/python_modules');
# from ClientForm import ParseResponse;

def downloadFasta(acc) :
    strUniprotFastaUrl = "http://www.uniprot.org/uniprot/%s.fasta";
    try :
        print "Trying to fetch '%s'" % strUniprotFastaUrl % acc;
        fastaResponse = urlopen(strUniprotFastaUrl % acc);
    except :
        print "Not found";
        return None;
    return fastaResponse.read().rstrip();

if __name__ == '__main__' :
    # Check $argv
    strUsage = "Usage: %s <search terms file> <outdir>";
    if ( len(sys.argv) < len(strUsage.split('<')) ) :
        print strUsage % os.path.basename(sys.argv[0]);
        sys.exit(1);

    strNamesFile = sys.argv[1];
    strOutdir = sys.argv[2].rstrip('/');

    strUniprotQueryUrl = "http://www.uniprot.org/uniprot/?query=%s&sort=score";

    ptnUniprotAcc = re.compile('<td style=""><a href="./\w+">(\w+)</a>');

    flhNames = file(strNamesFile);
    for strLine in flhNames :
        strQuery = strLine.strip().replace(' ','+');

        # try to get the file directly
        strFasta = downloadFasta(strQuery);
        if strFasta :
            strPrimaryAccession = strQuery;
        else :
            print "Going to %s" % strUniprotQueryUrl % strQuery;
            uniprotResponse = urlopen(strUniprotQueryUrl % strQuery);
            
            strUniprotResponse = uniprotResponse.read();
            m = ptnUniprotAcc.search(strUniprotResponse);
            if not m :
                flhFoo = file('./foo.html', 'w');
                print >>flhFoo, strUniprotResponse;
                flhFoo.close();
                # raise Exception("No accession match found for '%s'" % strQuery);
                print >>sys.stderr, "No accession match found for '%s'" % strQuery;
                continue ;
            strPrimaryAccession = m.group(1);
            print strPrimaryAccession;
            strFasta = downloadFasta(strPrimaryAccession);

        flhFasta = file(os.path.join(strOutdir, strPrimaryAccession + '.fa'), 'w');
        print >>flhFasta, strFasta;
        flhFasta.close();


    flhNames.close();
