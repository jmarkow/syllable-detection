
[b,a]=ellip(5,.2,40,[200 7e3]/(agg_audio.fs/2),'bandpass');

testdata=filtfilt(b,a,double(agg_audio.data));

%%%% insert filtering code to get to testdata

[extracted_sound,~,~,idxs]=zftftb_spectro_navigate(double(agg_audio.data(:,1)),agg_audio.fs);

template=filtfilt(b,a,extracted_sound);
[new_filter,hits]=fiberdata_matched_template(testdata(:,1:100),template,agg_audio.fs,'range',idxs);

%%%% optimize matched template for FIR order

% assume filter is new filter

order=length(new_filter);
step_size=50; % stepsize in samples
steps_forward=step_size:step_size:order;
buffer=500;

[nsamples,ntrials]=size(testdata);

snr_vec_forward=zeros(1,length(steps_forward));

for i=1:length(steps_forward)

	% matched template is flipped average, start moving from first to last point

	tmp_filter=new_filter(steps_forward(i):end);
	new_hitmat=filter(tmp_filter,1,testdata(:,50:100)).^2;

	target=idxs(1)-buffer:idxs(2)+buffer;
	target(target>nsamples)=[];
	target(target<1)=[];

	snr_vec_forward(i)=fiberdata_eval_filter_snr(new_hitmat,target);

end

% change to user input here

selection=400;
steps_backward=step_size:step_size:order-selection;
snr_vec_backward=zeros(1,length(steps_backward));

for i=1:length(steps_backward)

	tmp_filter=new_filter(selection:end-steps_backward(i));
	new_hitmat=filter(tmp_filter,1,testdata(:,50:100)).^2;

	target=idxs(1)-buffer:idxs(2)+buffer;
	target(target>nsamples)=[];
	target(target<1)=[];

	snr_vec_backward(i)=fiberdata_eval_filter_snr(new_hitmat,target);

end


% change to user input here

selection2=1450;
tmp_filter=new_filter(selection:end-selection2);

new_hitmat=filter(tmp_filter,1,testdata(:,1:200)).^2;
target=idxs(1)-buffer:idxs(2)+buffer;
target(target>nsamples)=[];
target(target<1)=[];

fiberdata_eval_filter_roc(new_hitmat,target);


