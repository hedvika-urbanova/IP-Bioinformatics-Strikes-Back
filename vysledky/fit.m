function[]=fit(pom,imageData,imageNames,path_result,avgt,count)

N=50;
sf=1;
cb=-1;

data=cell(count,7);
ii=size(imageData,1);
jj=size(imageData,2);

Sobel_x =[-1 0 1;-2 0 2; -1 0 1];
Sobel_y = Sobel_x';

c=0;
for i=1:ii
    for j=1:jj
        tic
        if ~isempty(imageData{i,j})
            name=imageNames{i,j};
            c=c+1;
            if  pom(i,j)
                img=double(imageData{i,j});
                img=(img-min(img(:)))/(max(img(:))-min(img(:)));
                Fx=conv2(img,Sobel_x,'same');
                Fy=conv2(img,Sobel_y,'same');
                F=sqrt(Fx.*Fx+Fy.*Fy);        
                L=graythresh(F);
                BW=im2bw(F,L);
                BW=imfill(BW,'holes');
                se=strel('disk',1,0);
                dil=imdilate(BW,se);
                A=imfill(dil,'holes');
                if sum(sum(A-BW))<2000
                   A=BW;
                end
                B=bwareaopen(A,500);
                if sum(sum(A-B))>2000
                    windowSize=11;        
                    kernel=ones(windowSize)/windowSize^2;
                    C=conv2(single(B),kernel,'same');
                    D=C>0.5;
                    se=strel('disk',10,0);
                    er=imerode(D,se);
                    E=activecontour(img,er,N,'Chan-Vese','SmoothFactor',sf,'ContractionBias',cb);
                else E=B;
                end
                se=strel('disk',1,0);
                er=imerode(E,se);
                H=E-er;
                rgb=zeros(size(img,1),size(img,2),3);
                img(H==1)=1;
                rgb(:,:,1)=img;
                img(H==1)=0;
                rgb(:,:,2)=img;
                rgb(:,:,3)=img;
                figure
                subplot 121
                imshow(rgb)
                subplot 122
                imshow(H)
                title(['Obraz ',int2str(j),' Kategoria ',int2str(i)])
                [x,y]=find(H);
                ellipse_t=fit_ellipse(x,y);
                if isempty(ellipse_t);
                    t=toc;
                    data{c,1}=name;
                    data{c,2}=[];
                    data{c,3}=[];
                    data{c,4}=[];
                    data{c,5}=[];
                    data{c,6}=[];
                    data{c,7}=(t+avgt)*1000;
                    continue
                else
                    ellipse(ellipse_t.b,ellipse_t.a,ellipse_t.phi,ellipse_t.Y0_in,ellipse_t.X0_in,'r',1000);
                    v=[ellipse_t.b,ellipse_t.a];
                    [~,indmax]=max(v);
                    [~,indmin]=min(v);
                    if indmax==2
                       deg=ellipse_t.phi/pi*180+90;
                    else deg=ellipse_t.phi/pi*180;
                    end
                    t=toc;
                    data{c,1}=name;
                    data{c,2}=round(ellipse_t.Y0_in);
                    data{c,3}=round(ellipse_t.X0_in);
                    data{c,4}=round(v(indmax));
                    data{c,5}=round(v(indmin));
                    data{c,6}=deg;
                    data{c,7}=(t+avgt)*1000;
                end               
            else t=toc;
                 data{c,1}=name;
                 data{c,2}=[];
                 data{c,3}=[];
                 data{c,4}=[];
                 data{c,5}=[];
                 data{c,6}=[];
                 data{c,7}=(t+avgt)*1000;
            end
        end
    end
end
fid = fopen(path_result,'wt');
header={'filename','ellipse_center_x','ellipse_center_y','ellipse_majoraxis','ellipse_minoraxis','ellipse_angle','elapsed_time'};
if fid>0
    fprintf(fid,'%s,%s,%s,%s,%s,%s,%s\n',header{1,:});
    for k=1:size(data,1)
        fprintf(fid,'%s,%i,%i,%i,%i,%f,%f\n',data{k,:});
    end
    fclose(fid);
end
end