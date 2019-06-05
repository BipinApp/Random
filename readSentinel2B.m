function [out] = readSentinel2B(file1,file2)
%out=[];
meta1 = xml2struct(file1);

out.date = meta1.n1_Level_1C_User_Product.n1_General_Info.Product_Info.PRODUCT_START_TIME.Text(1:10);
out.processing = meta1.n1_Level_1C_User_Product.n1_General_Info.Product_Info.Datatake.Attributes.datatakeIdentifier;
% for i =1 :13
%     out.Size{1,i}.NROWS = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Size{1,i}.NROWS.Text);
%     out.Size{1,i}.NCOLS = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Size{1,i}.NCOLS.Text);
%     
%     out.Geoposition{1,i}.ULX   = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,i}.ULX.Text);
%     out.Geoposition{1,i}.ULY   = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,i}.ULY.Text);
%     out.Geoposition{1,i}.XDIM  = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,i}.XDIM.Text);
%     out.Geoposition{1,i}.YDIM  = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,i}.YDIM.Text);
%     
% end
out.QValue =  str2num(meta1.n1_Level_1C_User_Product.n1_General_Info.Product_Image_Characteristics.QUANTIFICATION_VALUE.Text);

meta2 = xml2struct(file2);

out.SunAngle = str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Angles.Mean_Sun_Angle.ZENITH_ANGLE.Text);
out.AzimuthAngle = str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Angles.Mean_Sun_Angle.AZIMUTH_ANGLE.Text);

for m = 1:size(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Angles.Mean_Viewing_Incidence_Angle_List.Mean_Viewing_Incidence_Angle,2)
    
     out.MeanView(m,:) = str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Angles.Mean_Viewing_Incidence_Angle_List.Mean_Viewing_Incidence_Angle{1,m}.ZENITH_ANGLE.Text);
     out.MeanAzimuth(m,:)= str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Angles.Mean_Viewing_Incidence_Angle_List.Mean_Viewing_Incidence_Angle{1,m}.AZIMUTH_ANGLE.Text);
%      out.MeanView(m,:) = out.ViewAngle{1,m}.ZenithAngle;
%      out.MeanAzimuth(m,:) = out.ViewAngle{1,m}.AzimuthAngle;
end
     out.ViewAng = mean(out.MeanView);
     out.AzimuthAngSat = mean(out.MeanAzimuth);
     
%     out.Size{1,i}.NROWS = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Size{1,i}.NROWS.Text);
%     out.Size{1,i}.NCOLS = str2num(meta.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Size{1,i}.NCOLS.Text);
%     
    out.Eastmap   = str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,1}.ULX.Text);
    out.Northmap   = str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,1}.ULY.Text);
    %out.Geoposition{1,1}.XDIM  = str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,1}.XDIM.Text);
    %out.Geoposition{1,i}.YDIM  = str2num(meta2.n1_Level_1C_Tile_ID.n1_Geometric_Info.Tile_Geocoding.Geoposition{1,1}.YDIM.Text);
    
     dd   = datevec(out.date)
     prdd   = [dd(1,1)-1 12 31 0 0 0]
     testyr   = mod(dd(1,1),4)
  
  if   testyr == 0 ;    
       if  dd(1,2) < 3 ; out.JD = days365( datestr(prdd),datestr(dd));    % check if month is in Jan and Feb
           elseif dd(1,2) > 2 ; out.JD = days365( datestr(prdd),datestr(dd))+1; 
       end
  elseif testyr > 0 ; out.JD = days365( datestr(prdd),datestr(dd))  
  end 
      out.Dsqr  =  (1-0.01674 * cos(pi*(360/365.256363)*(out.JD-4)/180)).^2
     %d = 1-0.01674*COS(PI*(360/365.256363)*(JDAY-4)/180);
    %Hyperion [98Profile over Liybya4 with SZA within35 deg, and ViewAng 5 deg
  