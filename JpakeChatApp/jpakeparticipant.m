//
//  jpakeparticipant.m
//  coolhash
//
//  Created by Renu Srijith on 24/06/2015.
//  Copyright (c) 2015 newcastle university. All rights reserved.
//

#import "jpakeparticipant.h"

#import "jpakeParms.h"
static int const State_init =0;
static int const State_round1_create =10;
static int const State_round1_validate =20;
static int const State_round2_create =30;
static int const State_round2_validate =40;
static int const State_key_Create=50;
static int const State_round3_create =60;
static int const State_round3_validate=70;




@implementation jpakeparticipant


+ (void)initialize {
 
}
- (id)initWithParticipantId:(NSString *)ParticipantId
                  password :(NSString *)Password
{
    if( self = [super init] )
    {
        NSAssert([Password length]!=0, @"password should not be empty");
        self.participantId = ParticipantId;
        self.password=Password;
        
        self.p=[jpakeParms getP];
        self.q=[jpakeParms getQ];
        self.g=[jpakeParms getG];
        
        [self setState:State_init];
        
    }
    
    return self;


}



- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.participantId             forKey:@"participantId"];
    [coder encodeObject:self.password                  forKey:@"password"];
    [coder encodeObject:self.partnerParticipantId      forKey:@"partnerParticipantId"];
    
    [coder encodeObject:self.p  forKey:@"p"];
    [coder encodeObject:self.q forKey:@"q"];
    [coder encodeObject:self.g forKey:@"g"];
    [coder encodeObject:self.x1 forKey:@"x1"];
    [coder encodeObject:self.x2  forKey:@"x2"];
    [coder encodeObject:self.gx1 forKey:@"gx1"];
    [coder encodeObject:self.gx2 forKey:@"gx2"];
    [coder encodeObject:self.gx3 forKey:@"gx3"];
    [coder encodeObject:self.gx4 forKey:@"gx4"];
    //[coder encodeObject:self.state   forKey:@"state"];
    [coder encodeInt:self.states forKey:@"states"];
    
}

- (id)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if(self!=nil)
    {
        self.participantId  = [coder decodeObjectForKey:@"participantId"];
        self.password    = [coder decodeObjectForKey:@"password"];
        self.partnerParticipantId = [coder decodeObjectForKey:@"partnerParticipantId"];
        self.p=[coder decodeObjectForKey:@"p"];
        self.q=[coder decodeObjectForKey:@"q"];
        
        self.g=[coder decodeObjectForKey:@"g"];
        
        self.x1=[coder decodeObjectForKey:@"x1"];
        self.x2=[coder decodeObjectForKey:@"x2"];
        self.gx1=[coder decodeObjectForKey:@"gx1"];
        self.gx2=[coder decodeObjectForKey:@"gx2"];
        self.gx3=[coder decodeObjectForKey:@"gx3"];
        self.gx4=[coder decodeObjectForKey:@"gx4"];
        self.states=[coder decodeIntForKey:@"states"];


    }
    
    return self;
}


-(JpakeRound1Payload*)createRound1toSend
{
  
   NSAssert([self getState]== State_init, @"round 1 created already");
    self.x1 =[jpakeUtils generateX1:[self p]];
    self.x2 =[jpakeUtils generateX2:[self q]];
    
    self.gx1=[jpakeUtils calculateGx:[self p] g:[self g] x:[self x1]];
    self.gx2=[jpakeUtils calculateGx:[self p] g:[self g] x:[self x2]];

    
    NSArray *zkpX1=[jpakeUtils calculateZeroKnowledgeProof:[self p] Q:[self q] G:[self g] Gx:[self gx1] X:[self x1] ParticipantID:[self participantId]];
    
    
    NSArray *zkpX2=[jpakeUtils calculateZeroKnowledgeProof:[self p] Q:[self q] G:[self g] Gx:[self gx2] X:[self x2] ParticipantID:[self participantId]];
    [self setState:State_round1_create];
  
    JpakeRound1Payload *jround1=[[JpakeRound1Payload alloc]initWithParticipantId:[self participantId] gX1:[self gx1] gX2:[self gx2] ZkpX1:zkpX1 ZkpX2:zkpX2 ZkpX10:zkpX1[0] ZkpX11:zkpX1[1] ZkpX20:zkpX2[0] ZkpX21:zkpX2[1] ];
    return jround1;

}

-(void)validadateRound1PayloadReceived:(JpakeRound1Payload*)payload1
{
NSAssert([self getState] < State_round1_validate   , @"Validation already attempted for Round1 payload");
    self.partnerParticipantId =[payload1 getParticipantID];
    self.gx3=[payload1 getGx1];
    self.gx4=[payload1 getGx2];
    
    BigInteger *zkpx10=[[BigInteger alloc]initWithBigInteger:[payload1 getZkpX10]];
    BigInteger *zkpx11=[[BigInteger alloc]initWithBigInteger:[payload1 getZkpX11]];
    BigInteger *zkpx20=[[BigInteger alloc]initWithBigInteger:[payload1 getZkpX20]];
    BigInteger *zkpx21=[[BigInteger alloc]initWithBigInteger:[payload1 getZkpX21]];
   
    NSArray *zkpx1=[[NSArray alloc]initWithObjects:zkpx10,zkpx11, nil];
    NSArray *zkpx2=[[NSArray alloc]initWithObjects:zkpx20,zkpx21 ,nil];
    
    [jpakeUtils validateParticipantIdsDiffer:[self participantId] ParticipantID2:[payload1 getParticipantID]];
    [jpakeUtils validateGx4:[self gx4]];
    [jpakeUtils validateZeroKnowledgeProof:[self p] Q:[self q ] G:[self g] Gx:[self gx3] Nsarray:zkpx1 participantID:[payload1 getParticipantID]];
    

    [jpakeUtils validateZeroKnowledgeProof:[self p] Q:[self q ] G:[self g] Gx:[self gx4] Nsarray:zkpx2 participantID:[payload1 getParticipantID]];
    
    [self setState:State_round1_validate];
}

-(JpakeRound2Payload*)createRound2toSend
{
    NSLog(@"inside Create Round2toSend %d" ,[self getState]);
//    NSAssert([self getState]<State_round2_create, @"round 2 created already");
    BigInteger *gA =[jpakeUtils calculateGA:[self p] gx1:[self gx1] gx3:[self gx3] gx4:[self gx4]];
    BigInteger *s=[jpakeUtils calculateS:[self password]];
    BigInteger *x2S=[jpakeUtils calculateX2s:[self q] x2:[self x2] s:s];
    BigInteger *A=[jpakeUtils calculateA:[self p] q:[self q] gA:gA x2s:x2S];
    NSArray *ZKPX2s=[jpakeUtils calculateZeroKnowledgeProof:[self p] Q:[self q] G:gA Gx:A X:x2S ParticipantID:[self participantId]];
    
    
    [self setState:State_round2_create];

    JpakeRound2Payload *jround2=[[JpakeRound2Payload alloc]initWithParticipantId:[self participantId] a:A Zkpx2s:ZKPX2s Zkpx2s0:ZKPX2s[0] Zkpx2s1:ZKPX2s[1]];
    return jround2;


}

-(void)validadateRound2PayloadReceived:(JpakeRound2Payload *)payload2
{
    
    
    
    NSAssert([self getState] < State_round2_validate   , @"Validation already attempted for Round2 payload");
    BigInteger *gB=[jpakeUtils calculateGA:[self p] gx1:[self gx3] gx3:[self gx1] gx4:[self gx2]];
    self.b =[payload2 geta];
    
    BigInteger *zkpX4s0=[[BigInteger alloc]initWithBigInteger:[payload2 getZkpX2s0]];
    BigInteger *zkpX4s1=[[BigInteger alloc]initWithBigInteger:[payload2 getZkpX2s1]];
    
    NSArray *zkpX4s=[[NSArray alloc]initWithObjects:zkpX4s0,zkpX4s1, nil];
    [jpakeUtils validateParticipantIdsDiffer:[self participantId] ParticipantID2:[payload2 getParticipantID]];
    [jpakeUtils validateGx4:gB];
    [jpakeUtils validateZeroKnowledgeProof:[self p] Q:[self q] G:gB Gx:[self b] Nsarray:zkpX4s participantID:[payload2 getParticipantID]];
    
     [self setState:State_round2_validate];

}


-(BigInteger*)calculateKeyingMaterial
{
    NSAssert([self getState]<State_key_Create, @"key created already");
    BigInteger *s=[jpakeUtils calculateS:[self password]];
    BigInteger *key=[jpakeUtils calculateKeyingMaterial:[self p] Q:[self q] GX4:[self gx4] X2:[self x2] S:s B:[self b]];
    //extra work needs to be done here
    self.x1=nil;
    self.x2=nil;
    self.b=nil;
    
    [self setState:State_key_Create];
    
    return key;
    
}

-(JpakeRound3Payload*)createRound3toSend:(BigInteger*)keyingMaterial
{
    NSAssert([self getState]<State_round3_create, @"round3 creation already done");
   // NSAssert([self getState]<State_key_Create, @"round3  should be done after key generation");
    
    BigInteger *tag=[jpakeUtils calculateMacTag:[self participantId] partnerParticipantID:[self partnerParticipantId] gx1:[self gx1] gx2:[self gx2] gx3:[self gx3] gx4:[self gx4] keyingMaterial:keyingMaterial];
    [self setState:State_round3_create];
    JpakeRound3Payload *r3Payload=[[JpakeRound3Payload alloc]initWithParticipantId:[self participantId] macTag:tag];
    return r3Payload;
}

-(void)validateRound3Payloadreceived:(JpakeRound3Payload*)jpakeRound3  keyingmaterial:(BigInteger*)keyingMaterial

{

NSAssert([self getState]<State_round3_validate, @"round3 validation already done");
    
    //one step missing here
    
    [jpakeUtils validateParticipantIdsDiffer:[self participantId] ParticipantID2:[jpakeRound3 getParticipantID]];
  //one step missing here @
    [jpakeUtils validateMacTag:[self participantId] partnerParticipantId:[self partnerParticipantId] gx1:[self gx1] gx2:[self gx2] gx3:[self gx3] gx4:[self gx4] keyingMaterial:keyingMaterial partnerMacTag:[jpakeRound3 getMactag]];
    
    
    //steps missing

}

-(void)setState:(int)stateStatus
{
  state=stateStatus;
    self.states=state;
    
}

-(int)getState
{
    state=self.states;
    return state;
}

@end
