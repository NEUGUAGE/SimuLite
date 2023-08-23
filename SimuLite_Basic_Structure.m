%For new cam use webcamlist; Then Input the camera name to webcam('your_cam_name')
%%%%%%%%%%%%%%%%%Status_Parameter%%%%%%%%%%%%%%%%%%%%%%%%%%%
status=1; %This should be 1 if start button is clicked
%a = arduino();
%%%%%%%%%%%%%%CAMERA PART%%%%%%%%%%%%%%%%%%%%%
cam = webcam('Arducam OV9782 USB Camera');%Subject to change
pause(2);
img = snapshot(cam);
img_grey=rgb2gray(img);%img_grey is 255x255 matrix for current image

%%%%%%%%%%%%%%%Detection Parameters%%%%%%%%%%%%%%%%%%% %if it is running then,start detection
resolution_X=800;%subject to change
resolution_Y=1280;%subject to change
stimulation_area_X=1:400;% should be able to change and determine the stimulation area
stimulation_area_Y=1:400;
%determine simulation area
%%%%%%%%%%%%%%%Detection Codes%%%%%%%%%%%%%%%%%%%
tmp_img = double(img_grey);
tmp_img(:) = 0;
%start to scan for the background
total_scans = 30;
for i = 1:total_scans
    img = snapshot(cam);%
    img_grey=rgb2gray(img);
    tmp_img = tmp_img+double(img_grey)/255;
end
tmp_img = tmp_img/total_scans;%generate a background image
while status==1
    img = snapshot(cam);
    img_after_subtraction = tmp_img- double(rgb2gray(img))/255;
    subtraction_parameter=0.15;%determine the line between subtraction
    %make the image binary
    img_after_subtraction(img_after_subtraction>subtraction_parameter) = 1.0;
    img_after_subtraction(img_after_subtraction<=subtraction_parameter) = 0;
    %find the fly position
    tmp_x = sum(img_after_subtraction,1);
    [~,tmp_idx_x] = find(tmp_x>1);
    idx_x = mean(tmp_idx_x);
    tmp_y = sum(img_after_subtraction,2);
    [~,tmp_idx_y] = find(tmp_y'>1);
    idx_y = mean(tmp_idx_y);

    fly_location = [idx_y, idx_x];

%show the current position
    imagesc(img_after_subtraction);
    hold on; 
    plot(fly_location(2), fly_location(1), 'r.', 'markersize', 10);
    drawnow();
if any(stimulation_area_X==fly_location(1,1)) & any(stimulation_area_Y==fly_location(1,2))
    flystate=1;
else
    flystate=0;
end

%%%%%%%%%%%%%%%Stimulus code%%%%%%%%%%%%%%%%%%%%%%%%
%if flystate==1
   %disp("stimulation");
   %writeDigitalPin(a, 'D9', 1);
%else
   %writeDigitalPin(a, 'D9', 0);
%end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
