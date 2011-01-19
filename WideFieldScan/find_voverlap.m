function ov = find_voverlap(file1,file2,flat,dark)

  drk = double(imread(dark));
  flt = double(imread(flat)) - drk;
  im1 = ( double(imread(file1)) - drk ) ./ flt;
  im2 = ( double(imread(file2)) - drk ) ./ flt;
  
  figure(1)
  subplot(2,1,1)
  imshow(im1,[])
  subplot(2,1,2)
  imshow(im2,[])
  figure(2)
  imshow([im1;im2],[])
  [ ov displace ] = find_overlap(imrotate(im1,90),imrotate(im2,90),128,3,1);
  figure(4)
  if displace >= 0
    imshow([im1(1:displace,:);im2 ],[])
  else
    imshow([im2(1:abs(displace),:);im1 ],[])
  end
  axis on
  
end
