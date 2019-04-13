clc
close all
clear all

path_result='D:\Studium\8.semester\UnIT\vysledky\test.csv';

% String{1}='D:\Studium\8.semester\UnIT\unit-2019-develop\data\develop\Category 1 - Easy Fits';
% String{2}='D:\Studium\8.semester\UnIT\unit-2019-develop\data\develop\Category 2 - Hardly Fitable';
% String{3}='D:\Studium\8.semester\UnIT\unit-2019-develop\data\develop\Category 3 - Grid Cut-offs';
% String{4}='D:\Studium\8.semester\UnIT\unit-2019-develop\data\develop\Category 4 - Illumination States 1';
% String{5}='D:\Studium\8.semester\UnIT\unit-2019-develop\data\develop\Category 5 - Illumination States 2';
% String{6}='D:\Studium\8.semester\UnIT\unit-2019-develop\data\develop\Category 6 - Generally Hard';
 String{1}='D:\Studium\8.semester\UnIT\test';

for i=1:length(String)
    addpath(String{i});
end

tic
Dir=cell(1,length(String));
pom=[];
count=0;
for r=1:length(String)
    Dir{r} = dir(String{r});
    count=count+size(Dir{r},1)-2;
    for o=1:size(Dir{r},1)-2
        imageNames{r,o}=Dir{r}(2+o).name;
        imageData{r,o}=imread(Dir{r}(2+o).name);
        obr=im2double(imageData{r,o}); 
        obr=(obr-min(obr(:)))/(max(obr(:))-min(obr(:)));
        pra(r,o)=multithresh(obr);
        rozpt=(std(std(obr)))^2;
        bin=1000;
        histo=hist(obr(:),bin);
        peaky=findpeaks(histo);        
        if length(peaky)>2 
           peaky=findpeaks(peaky);
        end
        if pra(r,o)<0.25 && length(peaky)~=2 
           pom(r,o)=0;
        else  
        if rozpt>0.00000000005
           pom(r,o)=1;
        else
           pom(r,o)=0; 
        end
        end
    end
end
t=toc;
avgt=t/count;
fit(pom,imageData,imageNames,path_result,avgt,count);