img1 = phantom;
img2 = imnoise(img1,'salt & pepper',0.02);

[mssim ssim_map] = ssim_index(img1,img2);

mssim
figure
    imshow(ssim_map,[]);
figure
    imshow(img1,[])
figure
    imshow(img2,[])