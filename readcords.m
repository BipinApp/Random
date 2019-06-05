function [coords] = readcords(file)
coords=[];
getmeta = parse_json(fileread(file));

for i =1:5
  coords.corner(1,i) = getmeta.tileGeometry.coordinates{1,1}{1,i}{1,1}; 
  coords.corner(2,i) = getmeta.tileGeometry.coordinates{1,1}{1,i}{1,2}; 
end


end