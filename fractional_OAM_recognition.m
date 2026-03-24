clear 
close all
clc

%% polar expansion
img = imread('D:\1.5.jpg'); 
img=im2double(img);
img=img./max(max(img));
img = imrotate(img, 90);
img=fliplr(img);
[row,col]=size(img);
% imshow(img);
imwrite(img,'D:\1.5.png');

[center, radius1, radius2] = findDiscreteRingCenterAndRadius(img);
disp(['Symmetric center: (', num2str(center(1)), ', ', num2str(center(2)), ')']);
disp(['Symmetric radius: ', num2str(radius1)]);

noiseThreshold = 0.1;

[smoothedProfile,min_valley_position,min_valley_value] = polarexpansion(img, center, radius1, radius2, noiseThreshold);
disp(min_valley_position);
disp(min_valley_value);

%% curve fitting
% x=1.005:0.005:1.995;
% 
% load('D:\valley_value.mat');
% load('D:\valley_position.mat');
% y_intensity=valley_value;
% y_position=valley_position./1440.*2*pi;
% 
% cftool(x,y_position);
% cftool(x,y_intensity);

%% recognition
p=min_valley_position./1440.*2*pi;
I=min_valley_value;

fun=@(l) 0.1*abs(p-(-1.187*l+5.326))+abs(I-(3.896*l^2-11.64*l+8.707));

l1=1;
l2=2;

[l_min,f_min]=fminbnd(fun,l1,l2);

disp(['l：',num2str(l_min)]);

%%
function [smoothedProfile,min_valley_position,min_valley_value] = polarexpansion(image, center, radius1, radius2, noiseThreshold)

    [rows, cols] = size(image);

    theta = linspace(0, 2*pi, 1440); 
    x = center(1) + radius1 * cos(theta);
    y = center(2) + radius1 * sin(theta);
    
    x = round(x);
    y = round(y);
    validIdx = x > 0 & x <= cols & y > 0 & y <= rows;
    x = x(validIdx);
    y = y(validIdx);

    circularProfile = image(sub2ind(size(image), y, x));
    profile = circularProfile(:);
    profile = profile./max(profile);

    smoothedProfile = profile;
    smoothedProfile =smoothedProfile /max(smoothedProfile);
    
    isValley = islocalmin(smoothedProfile);
    
    valley_indices = find(isValley); 
    valley_values = smoothedProfile(valley_indices); 
    
    [min_valley_value, min_idx] = min(valley_values); 
    min_valley_position = valley_indices(min_idx);    

end

function [center, radius1, radius2] = findDiscreteRingCenterAndRadius(image)

    [row,col]=size(image);
    grayImage = image;
    
    filteredImage = imbinarize(grayImage,0.3);

    [y, x] = find(filteredImage);

    centerX = mean(x);
    centerY = mean(y);
    center = [centerX, centerY];
    

    distances = sqrt((x - centerX).^2 + (y - centerY).^2);
    maxD=min([max(distances),row-center(1),col-center(2),center(1),center(2)]);

    radius1 = mean(distances);
    radius2 = radius1;
end
