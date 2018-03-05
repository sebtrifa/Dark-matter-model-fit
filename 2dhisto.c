#include <fstream>
void output{
TFile *f = new TFile("CMS-EXO-16-048_Figure_010-a.root");
f.ls();
ofstream myfile1;
myfile1.open ("my.txt");
ofstream myfile2;
myfile2.open ("mx.txt");
ofstream myfile3;
myfile3.open ("cross.txt");
TH2D *h2 = new TH2D("h2","h2 title" , 100, 0, 2500, 100, 0, 1200);
for(i=0;i<=2500;i=i+10)
{
 for(j=0;j<=1200;j=j+30)
 {
h2 = (TH2D*)f.Get("Observed_limit");
if(h2->GetBinContent(h2->FindBin(i,j))!=0)
{
myfile1 << h2->GetBinContent(h2->FindBin(i,j));
myfile1 <<endl;
myfile2 << i;
myfile2 <<endl;
myfile3 << j;
myfile3 <<endl;
}
}
}
myfile1.close();
myfile2.close();
myfile3.close();
}
