close all;
size=2500;
im1= phantom(size);
im2= imnoise(phantom(size),'speckle',3);

[mssim ssim_map] = ssim_index(im1,im2);

figure
subplot(221)
    imshow(im1,[]);
    title('img1')
subplot(222)
    imshow(im2,[]);
    title('img2')
subplot(223)
    imshow(max(0, ssim_map).^4,[])
    title(['ssim_map^4, mssim:' num2str(mssim)],'Interpreter','none')
subplot(224)
    imshow(ssim_map,[])
    title(['ssim_map, mssim:' num2str(mssim)],'Interpreter','none')
