function [NEW_FILTER,TARGET_MATRIX]=fiberdata_load(AUDIO,TARGET_SOUND,FS,varargin)
%
%
%

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end



% smooth data

freq_range=[500 8e3]; % bandpass before collecting template
threshold=.15; % xcorr threshold for hits 
step_size=.008;
offset=0;
leakage=1;
order=1024-5;
onset_delay=.1;
range=[];
sigma=.001;
buffer=.005;

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
		case 'freq_range'
			freq_range=varargin{i+1};
		case 'threshold'
			threshold=varargin{i+1};
		case 'step_size'
			step_size=varargin{i+1};
		case 'offset'
			offset=varargin{i+1};
		case 'leakage'
			leakage=varargin{i+1};
		case 'order'
			order=varargin{i+1};
		case 'onset_delay'
			onset_delay=varargin{i+1};
		case 'range'
			range=varargin{i+1};
	end
end


AUDIO=zscore(AUDIO);
TARGET_SOUND=zscore(TARGET_SOUND);

[nsamples,ntrials]=size(AUDIO);

template=flipud(TARGET_SOUND(:));
norm_factor=template'*template;
len=length(template);

disp('Creating target vector...');

TARGET_MATRIX=zeros(size(AUDIO));
todel=[];

for i=1:ntrials

	score=conv(AUDIO(:,i),template,'same');
	score=score/norm_factor;

	[vals,locs]=findpeaks(score,'minpeakheight',threshold,'minpeakdistance',round(.1*FS));
	
	if ~isempty(range)
		flag1=locs<range(1);
		flag2=locs>range(2);
		to_del=flag1|flag2;
		vals(to_del)=[];
		locs(to_del)=[];
	end

	if isempty(vals)
		todel=[todel i];
		continue;
	end

	[sortvals,sortidx]=sort(vals(:),1,'descend');

	startpoint=(locs(sortidx(1))-len/2); % onset of match
	stoppoint=startpoint+len-1;	
	hitpoint=round(stoppoint-round(onset_delay*FS));

	TARGET_MATRIX(hitpoint,i)=1;

end

% convert to vector, columnwise

TARGET_MATRIX(:,todel)=[];
TARGET_MATRIX=TARGET_MATRIX(:);
AUDIO(:,todel)=[];
AUDIO=AUDIO(:);

AUDIO=AUDIO(1:end-mod(length(AUDIO),5));
TARGET_MATRIX=TARGET_MATRIX(1:length(AUDIO));

disp('Learning filter (grab a coffee/beer, this may take a while...');
%ha=adaptfilt.nlms(order,step_size,leakage,offset);
ha=adaptfilt.blmsfft(order,step_size,leakage,5);
%ha=adaptfilt.rls(order,leakage,std(AUDIO)*eye(order));
[y,e]=filter(ha,AUDIO,TARGET_MATRIX);
NEW_FILTER=ha.coefficients;
