%Do a Feedforward Net on the data
ffwd = 1;
%Do a Recurring Neural  Net
recn = 0;



i=15
totalset =[]
while i>3,
name = [num2str(i) '.csv'];
a = csvread(name);
totalset = [totalset;a]; %dont be stupid STUPID!
i=i-1
end

a=0
i=3
testset =[]
while i>0,
name = [num2str(i) '.csv'];
a = csvread(name);
testset = [testset;a]; %dont be stupid STUPID!
i=i-1
end

% Deleteall Zeroes
DeleteZero = totalset(:,5) == 0;
totalset(DeleteZero,:) = [];
DeleteZero = testset(:,5) == 0;
testset(DeleteZero,:) = [];

%% FEEDFORWARD NN

if ffwd == 1
x = totalset(:,2:4)';
t = totalset(:,5)';
t = dummyvar(t)';
net = feedforwardnet(10,'sgdm'); %sgdm for stochastic! traingd is gradient decent function, backpropagation
net = train(net,x,t);
view(net)
y = net(x);
perf = perform(net,y,t)

% TEST SET EVALUATION
xt = testset(:,2:4)';
tt = testset(:,5)';
tt = dummyvar(tt)';
yt = net(xt);
perf_test = perform(net,yt,tt)

% MODEL ACCURACY
tind = vec2ind(tt);
yind = vec2ind(yt);
percentErrors = sum(tind ~= yind)/numel(tind);

end


%% RECURRENT NN

if recn == 1
x = totalset(:,2:4)';
t = totalset(:,5)';
t = dummyvar(t)';
net = layrecnet(1:10,10,'traingd'); %1:2 is the delay ; traingd is gradient decent function, backpropagation

% we are missing this line 
%[Xs,Xi,Ai,Ts] = preparets(net,x,t);
% check: https://es.mathworks.com/help/nnet/ref/layrecnet.html
coutputlayer = classificationLayer('Name','coutput')
net = train(net,x,t);
view(net)
y = net(x);
perf = perform(net,y,t)
end

%% FEEDFORWARD NN (MINI BATCH) ---> "dnet"
dnet = feedforwardnet(10,'trainscg'); %sgdm for stochastic! traingd is gradient decent function, backpropagation
mini_batch_size = 15; 
    % The "window" takes 15 inputs to train the net in every epoch
number_of_epochs = 30;
    % We have 1,520,606 examples, 
    %if we aproximate to 1,500,000 /15 = 100,000 epochs to feed all data
dnet.trainParam.epochs=1;
e=1;

while i < number_of_epochs
    x_stochastic_init_chunk = randperm(size(x,2));
    % "x_stochastic_init_chunk" makes the Stocastic effect!!
    % QUITE IMPORTANT - basically it init the data randomly!

    for i=1:number_of_epochs
        k = x_stochastic_init_chunk(1+mini_batch_size*(i-1):mini_batch_size*i);
        [ dnet tr ] = train(dnet, x(:,k), t(:,k));
    end
    perf(e) = mean(mean(abs(t-dnet(x))))
    e=e+1;
end

%plot(perf_batch)
% try to see the performance



