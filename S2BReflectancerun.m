%Sentinel 2A TOA reflectance Calculation
%written by  Morakot  Kaewmanee   Jan 19, 2017
%Input
% ROI for each PICSsite folder => basedata
% S2A images folder =>sensor_location
% Outputfile folder  => OutputS2A

%%=================================
clear data processing refdata
if ispc
%   base = 'Y:\zdrive\SpecialNeeds\Morakot\RchangeLibya4\ImageMask\Libya1-data\Correction\';  %~\zdrive\ImageDrive\OLI.TIRS\L8\P039\R037\
    basedata = 'Z:\SpecialNeeds\BIPIN RAUT\Sentinel Value calculation\';
    sensor_location = 'Z:\ImageDrive\Sentinel\MSI-A\P189\R046\';
    OutputS2A = 'Z:\SpecialNeeds\BIPIN RAUT\OutputS2B\';
elseif isunix
%   base = '~/zdrive/SpecialNeeds/Morakot/RchangeLibya4/ImageMask/Libya1-data/Correction/';  %~/zdrive/ImageDrive/OLI.TIRS/L8/P039/R037/
    basedata = '~/zdrive/SpecialNeeds/Morakot/RchangeLibya4/ImageMask/ROI/';
    sensor_location = '~/zdrive/ImageDrive/Sentinel/MSI-2/P189/R046/';
    OutputS2A = '~/zdrive/SpecialNeeds/Morakot/OutputS2B/';
end

if ispc
   ls_file = ls(sensor_location);
   ls_file(1:2,:)=[];
elseif isunix
    list_temp = dir(sensor_location);
    count=0;
    for m=3:size(list_temp,1)-1
        count=count+1;
        ls_file(count,:)=list_temp(m).name;
    end
    clear list_temp count
end

%%---Read ROI for each PICS Site

%%
roi_basename = 'Copy_of_Niger1_ROI_OPT.txt';
PICSname     = 'Niger1';
factor = 10;
%%
roi_filename = fullfile(basedata, roi_basename);
	
% Make sure it can be found.
    if ~exist(roi_filename, 'file')
        disp(['MAIN:  Cannot find ROI definition file ' roi_filename])
        return
    end
	
% Open the file to read.
	roi_fid = fopen(roi_filename, 'r');
	if roi_fid < 0
        disp(['MAIN:  Cannot read ROI definition file ' roi_filename])
        return
    end
    roi_coords = textscan(roi_fid, '%d %d', 'commentstyle', '//');
    Mapx = double(roi_coords{1,1}(:,:));  Mapx(5,1)=Mapx(1,1);
    Mapy = double(roi_coords{1,2}(:,:));  Mapy(5,1)=Mapy(1,1);
    
%Rearrange Mapx Mapy
    MapRoix = Mapx;  MapRoix (3,1)=Mapx(4,1); MapRoix (4,1)=Mapx(3,1);
    MapRoiy = Mapy;  MapRoiy (3,1)=Mapy(4,1); MapRoiy (4,1)=Mapy(3,1);
    
    if PICSname     == 'Sudan1'   %  check to see if Sudan/Egypt is used
       MapRoiy = Mapy-15000;  MapRoiy (3,1)=Mapy(4,1); MapRoiy (4,1)=Mapy(3,1);
    elseif PICSname  == 'Egypt1'
       MapRoiy = Mapy-1000;  MapRoiy (3,1)=Mapy(4,1); MapRoiy (4,1)=Mapy(3,1);
    else
       MapRoiy = Mapy;  MapRoiy (3,1)=Mapy(4,1); MapRoiy (4,1)=Mapy(3,1);
    end
	fclose(roi_fid);

%======================================
%==== Loop each image folder===========
for j = 1 :size(ls_file,1)
     basefile = strcat(sensor_location,ls_file(j,:),'\');
     basefile = strcat(basefile,'MSIL1C\');
     ls_bfile = ls(basefile);
     for num = 1:size(ls_bfile,1)
        if strfind(ls_bfile(num,:),'.jp2')
            indexValue(num) = 1;
        else
            indexValue(num) = 0;
        end
     end
     ls_bfile = ls_bfile(logical(indexValue'),:);
     
     metadata = strcat(basefile,'MTD_MSIL1C.xml'); %ls_bfile(end-1,:));
     imagedata = strcat(basefile,'MTD_TL.xml');
    
     data.image(j) = readSentinel2B(metadata,imagedata);
     
     [doy,fraction,dcD] = date2doy(datenum(data.image(j).date));
 
 %Extent of S2A Tile
     EastMap = data.image(j).Eastmap;
     NorthMap = data.image(j).Northmap;
 

 %==== for each band  calculate TOA reflectance wrt ROI 
    for i = 1:13
 
 % Transform image to projective coords 
 
        if i == 2 | i == 3 | i== 4 | i== 8
          dx= 10;
          dy=-10;
        elseif i == 5| i ==6| i ==7| i ==11| i ==12| i ==13
          dx= 20;
          dy=-20;
        elseif i == 10| i ==9| i ==1
          dx= 60;
          dy=-60;
        end
        x11 = EastMap(1)-dx/2;  % 5,10,30 meters east of the upper left corner
        y11 = NorthMap(1)+dx/2;
        R = makerefmat(x11, y11, dx, dy)
        data.R(j,i).Refim= R;
        [row,col] = map2pix(R,MapRoix,MapRoiy);
        Qvalue = data.image(j).QValue;
% Extract image for that ROI region
        image = double(imread(strcat(basefile,ls_bfile(i,:)),'PixelRegion',...
                {[round(row(1)) round(row(3))],[round(col(1)) round(col(3))]}));
%         figure(15)
%         imagesc(image);
%         line(col,row);
        %meanrad1nV(i,j)= (double(mean(nonzeros(image(:)))))/(cosd(data.image(j).ViewAng)*cosd(data.image(j).SunAngle));
        %meanref1nV(i,j)= (double(mean(nonzeros(image(:))))/10000)/(cosd(data.image(j).ViewAng)*cosd(data.image(j).SunAngle));
        refdata(i,j)   = (double(mean(nonzeros(image(:))))/Qvalue);
        stdradnV(i,j)  = double((std(nonzeros(image(:)))));
        dslnV(j,:)     = datenum(data.image(j).date) - datenum('2017-03-07');
        processing(j,:)= data.image(j).processing;
        refdata(15,j)     = dslnV(j,:);
        refdata(21,j) = dcD;
        
        
     if i == 2
            imSZA             = double(imread(strcat(basefile,'Sun_Zenith.tif')));
            imSZA             = imcrop(imSZA,[round(col(1)) round(row(1)) round(col(3))  round(row(3))]);
            refdata(16,j)     = (double(mean(nonzeros(imSZA(:)))/factor));
      
            imVZA             = double(imread(strcat(basefile,'View_Zenith.tif'))); 
            imVZA             = imcrop(imVZA,[round(col(1)) round(row(1)) round(col(3))  round(row(3))]);
            refdata(17,j)     = (double(mean(nonzeros(imVZA(:)))/factor));
      
            imSAzi            = double(imread(strcat(basefile,'Sun_Azimuth.tif')));
            imSAzi            = imcrop(imSAzi,[round(col(1)) round(row(1)) round(col(3))  round(row(3))]);
            refdata(19,j)     = (double(mean(nonzeros(imSAzi(:)))/factor));
      
            imVAzi            = double(imread(strcat(basefile,'View_Azimuth.tif')));
            imVAzi            = imcrop(imVAzi,[round(col(1)) round(row(1)) round(col(3))  round(row(3))]);
            refdata(20,j)     = (double(mean(nonzeros(imVAzi(:)))/factor));
            clear imSZA imVZA imSAzi imVAzi   
        else
        end
   end;
   
         
         
 end

base1 = 'Z:\SpecialNeeds\BIPIN RAUT\Sentinel Value calculation\';
file1=strcat('S2A-SDSU',PICSname);   %  Change filename here for each PICS site
format shortg
c = clock
Filename = strcat(file1,num2str(i),num2str(c(1,2)),num2str(c(1,3)),num2str(c(1,1)),num2str(c(1,4)),num2str(c(1,5)));
%save(strcat(base1,Filename,'.mat'),'data','refdata','dslnV','meanrad1nV','meanref1nV','processing','-v7.3');
save(strcat(base1,Filename,'.mat'),'data','refdata','dslnV','processing','-v7.3');