function Sinogram = h_CorrectRotCenter(Sinogram,Difference)
% takes inputimage and pads it with 'Difference' pixels on the right end of
% the inputimage, so that the rotation-centre is shifted (a bad hack...)
% The function also accepts negative differences...

DiffImg=zeros(size(Sinogram,1),abs(Difference));
% DiffImg=ones(size(Sinogram,2),abs(Difference));
% SinogramSize=size(Sinogram)
% DifferenceSize=Difference
% DiffImgSize=size(DiffImg)

if Difference > 0
    Sinogram = cat(2, Sinogram, DiffImg);
elseif Difference < 0
    Sinogram = cat(2, DiffImg, Sinogram);
else
    % do nothing...
end
clear DiffImg;

end