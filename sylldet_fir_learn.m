function [NEW_FILTER,TARGET_MATRIX]=sylldet_fir_learn(AUDIO,TARGET_SOUND,FS,varargin)
%
%
%

if ~isa(AUDIO,'double')
	AUDIO=double(AUDIO);
end

if ~isa(TARGET_SOUND,'double')
	TARGET_SOUND=double(TARGET_SOUND);
end

% smooth data

threshold=.1; % xcorr threshold for hits 
step_size=.0008;
offset=1e-9;
leakage=1;
order=2000;
onset_delay=0;
range=[];
sigma=.001;
filt_type='lms';
empty_trials=1;
block_size=3;
jitter=5;
marker_jitter=300;
marker=[];

nparams=length(varargin);

if mod(nparams,2)>0
	error('ephysPipeline:argChk','Parameters must be specified as parameter/value pairs!');
end

for i=1:2:nparams
	switch lower(varargin{i})
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
		case 'marker'
			marker=varargin{i+1};
		case 'filt_type'
			filt_type=varargin{i+1};
		case 'block_size'
			block_size=varargin{i+1};
		case 'empty_trials'
			empty_trials=varargin{i+1};
		case 'jitter'
			jitter=varargin{i+1};
		case 'marker_jitter'
			marker_jitter=varargin{i+1};
	end
end

[nsamples,ntrials]=size(AUDIO);

template=flipud(zscore(TARGET_SOUND(:)));
norm_factor=template'*template;
template=template/norm_factor;

len=length(template);

disp('Creating target vector...');

TARGET_MATRIX=zeros(size(AUDIO));
todel=[];

score=filter(template,1,zscore(AUDIO));

for i=1:ntrials

	[vals,locs]=findpeaks(score(:,i),'minpeakheight',threshold,'minpeakdistance',round(.1*FS));
	
	if ~isempty(marker)
		flag1=locs<marker-marker_jitter;
		flag2=locs>marker+marker_jitter;
		to_del=flag1|flag2;
		vals(to_del)=[];
		locs(to_del)=[];
	end

	if isempty(vals)
		todel=[todel i];
		continue;
	end

	[sortvals,sortidx]=sort(vals(:),1,'descend');

	stoppoint=locs(sortidx(1));
	hitpoint=round(stoppoint-round(onset_delay*len));

	hitpoints=hitpoint-jitter:hitpoint+jitter;
	hitpoints(hitpoints<1|hitpoints>nsamples)=[];

	TARGET_MATRIX(hitpoints,i)=1;

end

% convert to vector, columnwise

if empty_trials
	disp(['Deleting ' num2str(length(todel)) ' empty trials...']);
	TARGET_MATRIX(:,todel)=[];
	AUDIO(:,todel)=[];
	[nsamples,ntrials]=size(AUDIO);
end

disp('Learning filter (grab a coffee/beer, this may take a while)...');

switch lower(filt_type(1))

	case 'l'
		ha=adaptfilt.lms(order,step_size,leakage);

	case 'n'
		% so far most reliable, good tradeoff between performance and speed

		ha=adaptfilt.nlms(order,step_size,leakage,offset);

	case 'b'

		% great if you can use it, but seems highly unstable

		chop=mod(nsamples,block_size);
		AUDIO=AUDIO(1:end-chop,:);
		TARGET_MATRIX=TARGET_MATRIX(1:end-chop,:);

		order=2^nextpow2(order)-block_size;
		disp(['Setting order to ' num2str(order) '...']);	
		ha=adaptfilt.blmsfft(order,step_size,leakage,block_size);

	case 'r'

		% incredibly slow at higher order, unclear if we get a performance gain

		ha=adaptfilt.rls(order,leakage,std(AUDIO(:))*eye(order));

	otherwise

end

ha.PersistentMemory=true;

for i=1:ntrials
	disp(['Trial ' num2str(i) ]);
	[y,e]=filter(ha,AUDIO(:,i),TARGET_MATRIX(:,i));
end

NEW_FILTER=ha.coefficients;
