function h_GenerateSinograms(Filename,maxImgNum,SinRow)
% takes an input filename (according to the directory) an amount of
% sinograms and an amount of rows (meaning how many sinograms should be
% generated, since one row equals one sinogram).

loadpath = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/';
savepath = ['/afs/psi.ch/user/h/haberthuer/slsbl/x02da/e11126/Data2/_conca/' Filename '/sin/'];

%supress directory already exists message....
[s,mess,messid]=mkdir([ savepath ]);

%% load Image(s) from InputDir
for SinogramRow = SinRow
    SinogramRowStr = [ sprintf('%04d',SinogramRow) ];
        
    progress = waitbar(0,['I`m working on sinogram ' num2str(SinogramRow) ', please wait...']);
    for ImageNumber=1:maxImgNum
        ImageNumberStr = [ sprintf('%04d',ImageNumber) ; sprintf('%04d',ImageNumber) ];
        % load row from image
        InputImage = single(imread([ loadpath num2str(Filename) '/tif/' num2str(Filename) num2str(ImageNumberStr(2,:)) '.tif']));
        % figure;
        %    imshow(InputImage,[])
        % append to sinogram
        Sinogram(ImageNumber,:) = InputImage(SinogramRow,:);
        waitbar(ImageNumber/maxImgNum);
    end
    close(progress)
        
    Sinogram = Sinogram - min(min(Sinogram));
    Sinogram = Sinogram / max(max(Sinogram));
    figure;
        imshow(Sinogram,[])
    imwrite(Sinogram,[ savepath num2str(Filename) num2str(SinogramRowStr) '.sin.tif']);
end

%% Clear stuff that is not used anymore....
clear InputImage;
clear Sinogram;
end