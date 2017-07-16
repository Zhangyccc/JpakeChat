//
//  ChatVCTableViewController.m
//  JpakeChatApp
//
//  Created by Renu Srijith on 01/06/2016.
//  Copyright © 2016 newcastle university. All rights reserved.
//

#import "ChatVCTableViewController.h"
#import "theCoreDataStack.h"
#import "DataBasics.h"

#import "JSQMessage.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVKit/AVKit.h>
@import MobileCoreServices;
@import Firebase;

#import "NSData+AES256.h"

#import "NSString+SHA256.h"

#import "jpakeUtils.h"

#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonKeyDerivation.h>







@interface ChatVCTableViewController ()

@end

@implementation ChatVCTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getKey];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    
    self.senderId=[DataBasics dataBasicsInstance].currentUser.uId;
    self.senderDisplayName=[DataBasics dataBasicsInstance].currentUser.userEmail;

    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    self.showLoadEarlierMessagesHeader = NO;
    
    //Button for sending Image and Video
    //self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    
    
    self.msgArray =[[NSMutableArray alloc] init];
}

- (NSString *) encryptString:(NSString*)plaintext withKey:(NSString*)key withIV:(NSData*)ivString{
    NSData *data = [[plaintext dataUsingEncoding:NSUTF8StringEncoding] AES256EncryptWithKey:key iv:&ivString];
    return [data base64EncodedStringWithOptions:kNilOptions];
}

- (NSString *) decryptString:(NSString *)ciphertext withKey:(NSString*)key withIV:(NSData*)iVString {
    NSData *data = [[NSData alloc] initWithBase64EncodedString:ciphertext options:kNilOptions];
    return [[NSString alloc] initWithData:[data AES256EncryptWithKey:key iv:&iVString] encoding:NSUTF8StringEncoding];
}



-(NSString* ) encryptwithIV :(NSString*)text withkey:(NSData*)key withIV:(NSData*)iv{
    NSData *dataIn=[text dataUsingEncoding:NSUTF8StringEncoding];
    size_t         encryptBytes = 0;
    NSMutableData *encrypted  = [NSMutableData dataWithLength:text.length + kCCBlockSizeAES128];
    CCCrypt(kCCEncrypt,
            kCCAlgorithmAES,
            kCCOptionPKCS7Padding, // CBC is the default mode
            key.bytes, kCCKeySizeAES128,
            iv.bytes,
            dataIn.bytes, dataIn.length,
            encrypted.mutableBytes, encrypted.length,
            &encryptBytes);
    encrypted.length = encryptBytes;
    
    return [encrypted base64EncodedStringWithOptions:0];
    
}

-(NSString* ) decryptwithIV :(NSString*)text withkey:(NSData*)key withIV:(NSData*)iv{
    
    NSData *dataIn = [[NSData alloc] initWithBase64EncodedString:text options:0];
    
    
    size_t         decryptBytes = 0;
    NSMutableData *decrypted  = [NSMutableData dataWithLength:text.length + kCCBlockSizeAES128];
    CCCrypt(kCCDecrypt,
            kCCAlgorithmAES,
            kCCOptionPKCS7Padding, // CBC is the default mode
            key.bytes, kCCKeySizeAES128,
            iv.bytes,
            dataIn.bytes, dataIn.length,
            decrypted.mutableBytes, decrypted.length,
            &decryptBytes);
    decrypted.length = decryptBytes;
    
    
    
    return [[NSString alloc]initWithData:decrypted encoding:NSUTF8StringEncoding];
    
}








-(void)getKey{
    
    NSLog(@"hello inside the getKey method !");
    theCoreDataStack *coreDataStack=[theCoreDataStack defaultStack];
    NSEntityDescription *entityKey = [NSEntityDescription entityForName:@"JKey" inManagedObjectContext:coreDataStack.managedObjectContext];
    
    
    NSFetchRequest *requestKey = [[NSFetchRequest alloc] init];
    [requestKey setEntity:entityKey];
    NSPredicate *predKey =[NSPredicate predicateWithFormat:@"%K == %@ AND  %K == %@",@"toName",self.otherUser.userEmail,@"myName",self.currentUser.userEmail];
    [requestKey  setPredicate:predKey];
    
    NSSortDescriptor *sortDescriptorkey = [NSSortDescriptor sortDescriptorWithKey:@"toName" ascending:YES];
    
    [requestKey setSortDescriptors:@[sortDescriptorkey]];
    
    NSError *error1;
    NSArray *objectsKey = [coreDataStack.managedObjectContext executeFetchRequest:requestKey
                                                                            error:&error1];
    int obkc = (int)objectsKey.count;
    NSLog(@"objectsKey count is: %lu", (unsigned long)[objectsKey count]);
    //if ([objectsKey count] == 1)
    if(obkc == 1)
    {
        for(NSManagedObject *object in objectsKey)
            
        {
            NSLog(@"Getting alice key call  class");
            NSString* keyString=[object valueForKey:@"key"];
            self.key=keyString;
            
            
        }
        
        NSData *nsdataFromBase64String = [[NSData alloc] initWithBase64EncodedString:self.key options:0];
        
        NSString *plainstring = @"ENC";
        NSData *dataEnc = [plainstring dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *concatenatedData = [NSMutableData data];
        [concatenatedData appendData:nsdataFromBase64String];
        [concatenatedData appendData:dataEnc];
        
        NSString *string1 =[concatenatedData base64EncodedStringWithOptions:0];
        
        
        self.kenc=[string1 SHA256];
        self.kencData=[self.kenc dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSString *plainstring2 = @"MAC";
        NSData *dataEnc2 = [plainstring2 dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *concatenatedData1 = [NSMutableData data];
        [concatenatedData1 appendData:nsdataFromBase64String];
        [concatenatedData1 appendData:dataEnc2];
        
        
        
        
        NSString *string11 = [concatenatedData1 base64EncodedStringWithOptions:0];
        self.kmac=[string11 SHA256];
        self.kmacData=[self.kmac dataUsingEncoding:NSUTF8StringEncoding];
        
        
        
    }
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.senderId=[DataBasics dataBasicsInstance].currentUser.uId;
    self.senderDisplayName=[DataBasics dataBasicsInstance].currentUser.userEmail;

    [super viewWillAppear:YES];
    
    [self checkForMsges:self.otherUser];
    
    
}


-(void)checkForMsges:(User*)otherUser{
    NSLog(@"checkfrMsges ");
    FIRDatabaseReference *conversations=[[DataBasics dataBasicsInstance]pathToConversation:self.conversationId];
    
    [conversations observeSingleEventOfType:FIRDataEventTypeValue
     
                                  withBlock:^(FIRDataSnapshot *snapshot) {
                                      
                                      [self loadMessagesForConversation:self.conversationId];
                                      
                                      
                                  }];
    
    
    
}
- (NSData *)randomDataOfLength:(size_t)length {
    NSMutableData *data = [NSMutableData dataWithLength:length];
    
    int result = SecRandomCopyBytes(kSecRandomDefault,
                                    length,
                                    data.mutableBytes);
    NSAssert(result == 0, @"Unable to generate random bytes: %d",
             errno);
    
    return data;
}

-(void)loadMessagesForConversation:(NSString*)convID
{
    NSLog(@"inside load messages !! ");
    FIRDatabaseReference *msgRef=[[DataBasics dataBasicsInstance]pathToConversation:convID];
    [[msgRef queryLimitedToFirst:25 ]observeEventType:FIRDataEventTypeChildAdded withBlock:^(FIRDataSnapshot *snapshot) {
        NSString *txt=snapshot.value[@"text"];
        
        
        NSString *otherUser=snapshot.value[@"sender"];
        NSString *otherUSerEmail=snapshot.value[@"displayName"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
        
        NSString *iv=snapshot.value[@"iv"];
        NSString *macTag=snapshot.value[@"macTag"];
        
        
        NSData *ivData=[[NSData alloc]initWithBase64EncodedString:iv options:kNilOptions];
        
        NSData *dataEncTxt = [txt dataUsingEncoding:NSUTF8StringEncoding];
        
        
        NSMutableData *concatenatedData1 = [NSMutableData data];
        [concatenatedData1 appendData:ivData];
        [concatenatedData1 appendData:dataEncTxt];
        
        NSString *string11=[concatenatedData1 base64EncodedStringWithOptions:0];
        NSString *hmac=[jpakeUtils hmac:string11 withKey:self.kmac];
        
        NSLog(@"hmac %@ ",hmac);
        NSLog(@"mac Tag %@",macTag);
        
        
        
        
        //NSLog(@"text to be decrypted :%@ IV :%@",txt,ivData);
        
        //        NSData *dataEncTxt = [txt1 dataUsingEncoding:NSUTF8StringEncoding];
        //
        //
        //        NSMutableData *concatenatedData1 = [NSMutableData data];
        //        [concatenatedData1 appendData:dataEncTxt];
        //        [concatenatedData1 appendData:ivData];
        //
        
        
        // NSLog(@"txt :%@ ::: concatendated data :%@  dataenctxt :: %@ ",txt1,concatenatedData1,dataEncTxt);
        
        
        
        
        //        NSMutableString *string = [NSMutableString stringWithString:txt1];
        //        [string appendString:iv];
        //         NSString *hmac2=[jpakeUtils hmac:string withKey:self.kmac];
        
        if([hmac isEqualToString:macTag]){
            NSLog(@"cool mactage matched");
            NSString *txt1 =[self decryptwithIV:txt withkey:self.kencData withIV:ivData];
            //NSLog(@"txt1 after decryption %@",txt1);
            
            
            
            JSQMessage *msg=[[JSQMessage alloc]initWithSenderId:otherUser senderDisplayName:otherUSerEmail date:date text:txt1];
            //NSLog(@"jsqmsg %@",msg);
            [self.msgArray addObject:msg];
            [self finishReceivingMessage ];
            
            
        }
        else{
            NSLog(@"cool mactage not  matched");
            [self errorManagement:@"MAc Tag Mismatch" message:@"Mactag not matching"];
            
        }
        
        //        if([hmac2 isEqualToString:macTag]){
        //            NSLog(@"cool mactage matched seconf");}
    }];
    
    
    
}


- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.msgArray objectAtIndex:indexPath.item];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.msgArray count];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.msgArray objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}


//Sender's avatar image
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //return nil;
    UIImage *userImage = [UIImage imageWithData:[NSData dataWithContentsOfURL: [NSURL URLWithString:[FIRAuth auth].currentUser.photoURL.absoluteString]]];
    return [JSQMessagesAvatarImageFactory avatarImageWithImage:userImage diameter:30];
}



- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message = [self.msgArray objectAtIndex:indexPath.item];
    if(message.isMediaMessage){
        JSQVideoMediaItem *mediaItem = message.media;
        AVPlayer *player = [AVPlayer playerWithURL:mediaItem.fileURL];
        AVPlayerViewController *playerViewController = [AVPlayerViewController new];
        playerViewController.player = player;
        [self.view addSubview:playerViewController.view];
        [self presentViewController:playerViewController animated:YES completion:nil];
    }
}




//Send button
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
{
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    NSData *iv = [self randomDataOfLength:kCCKeySizeAES128];
    NSLog(@"IV %@",iv);
    NSString *ivStringtoStore = [iv base64EncodedStringWithOptions:kNilOptions];
    NSLog(@"ivString %@",ivStringtoStore);
    
    
    
    
    NSString *text1=[self encryptwithIV:text withkey:self.kencData withIV:iv];
    
    NSData *dataEncTxt = [text1 dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *concatenatedData1 = [NSMutableData data];
    [concatenatedData1 appendData:iv];
    [concatenatedData1 appendData:dataEncTxt];
    NSString *string11=[concatenatedData1 base64EncodedStringWithOptions:0];
    NSString *hmac=[jpakeUtils hmac:string11 withKey:self.kmac];
    
    NSLog(@"hmac %@",hmac);
    
    // NSLog(@"text1 message after encrypting with IV %@ ::: key before encryption %@",text1,self.kencData);
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text1];
    
    
    [[DataBasics dataBasicsInstance]sendMessage:message convID:self.conversationId macTag:hmac iv:ivStringtoStore];
    [self finishSendingMessageAnimated:YES];
    
    
    NSLog(@"%@",message);
}

//Image and Video
- (void)didPressAccessoryButton:(UIButton *)sender{
    //[JSQSystemSoundPlayer jsq_playMessageSentSound];
    //alert --> UIAlertControllerStyleActionSheet : alert appear from the bottom
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Media Message" message:@"Please Select a Media" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *CancelButton =[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    //Photo
    UIAlertAction *PhotosButton = [UIAlertAction actionWithTitle:@"Photos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            UIAlertController *alertForPhoto = [UIAlertController alertControllerWithTitle:@"Error Message" message:@"Device has no photo library!" preferredStyle:UIAlertControllerStyleAlert];
            [self presentViewController:alertForPhoto animated:YES completion:nil];
        }
//Deprecated code before iOS 9.0
//            UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                                  message:@"Device has no photo library."
//                                                                 delegate:nil
//                                                        cancelButtonTitle:@"OK"
//                                                        otherButtonTitles: nil];
//            
//            [myAlertView show];
        else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
            [self presentViewController:picker animated:YES completion:nil];
        }
    }];
    //Video
    UIAlertAction *VideoButton = [UIAlertAction actionWithTitle:@"Videos" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                UIAlertController *alertForVideo = [UIAlertController alertControllerWithTitle:@"Error Message" message:@"Device has no photo library!" preferredStyle:UIAlertControllerStyleAlert];
                [self presentViewController:alertForVideo animated:YES completion:nil];
            }
        }
        else{
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
            [self presentViewController:picker animated:YES completion:nil];
        }
    }];
    [alert addAction:CancelButton];
    [alert addAction:PhotosButton];
    [alert addAction:VideoButton];
    [self presentViewController:alert animated:YES completion:nil];

}
//withSenderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date //(NSDictionary<NSString *,id> *)
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSDate *date = [NSDate date];
    //Image
    if([info[UIImagePickerControllerMediaType] isEqualToString: (__bridge NSString *)(kUTTypeImage)]){
        NSLog(@"Detected image");
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        NSString *stringImage = [self encodeToBase64String:image];
        //the length of stringImage is so long... this will crash the pc in 10 seconds...
        //NSLog(@"String Image : %@", stringImage);
//        [JSQSystemSoundPlayer jsq_playMessageSentSound];
//        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:stringImage];
        //IV
        NSData *iv = [self randomDataOfLength:kCCKeySizeAES128];
        NSLog(@"IV of image %@",iv);
        NSString *ivStringtoStore = [iv base64EncodedStringWithOptions:kNilOptions];
        NSLog(@"ivString of image %@",ivStringtoStore);
        
        NSString *EncryptedImage=[self encryptwithIV:stringImage withkey:self.kencData withIV:iv];
        NSData *dataEncTxt = [EncryptedImage dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *concatenatedData1 = [NSMutableData data];
        [concatenatedData1 appendData:iv];
        [concatenatedData1 appendData:dataEncTxt];
        NSString *EncodeImage=[concatenatedData1 base64EncodedStringWithOptions:0];
        NSString *hmac=[jpakeUtils hmac:EncodeImage withKey:self.kmac];
        NSLog(@"hmac for image is: %@",hmac);
        
        // NSLog(@"text1 message after encrypting with IV %@ ::: key before encryption %@",text1,self.kencData);
        
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[FIRAuth auth].currentUser.uid
                                                 senderDisplayName:[FIRAuth auth].currentUser.email
                                                              date:date
                                                              text:EncryptedImage];
        
        
        [[DataBasics dataBasicsInstance]sendMessage:message convID:self.conversationId macTag:hmac iv:ivStringtoStore];
        [self finishSendingMessageAnimated:YES];
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        NSLog(@"image : %@",message);

    }
    //Video
    else{
        NSLog(@"Detected video");
        NSURL *video = [info objectForKey:UIImagePickerControllerMediaURL];
        NSString *stringVideo = video.absoluteString;
        NSLog(@"String Video: %@", stringVideo);
//        [JSQSystemSoundPlayer jsq_playMessageSentSound];
//        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:senderDisplayName date:date text:video.absoluteString];
        //IV
        NSData *iv = [self randomDataOfLength:kCCKeySizeAES128];
        NSLog(@"IV of video: %@",iv);
        NSString *ivStringtoStore = [iv base64EncodedStringWithOptions:kNilOptions];
        NSLog(@"ivString of video: %@",ivStringtoStore);
        
        NSString *EncryptedVideo=[self encryptwithIV:stringVideo withkey:self.kencData withIV:iv];
        NSData *dataEncTxt = [EncryptedVideo dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *concatenatedData1 = [NSMutableData data];
        [concatenatedData1 appendData:iv];
        [concatenatedData1 appendData:dataEncTxt];
        NSString *EncodeVideo=[concatenatedData1 base64EncodedStringWithOptions:0];
        NSString *hmac=[jpakeUtils hmac:EncodeVideo withKey:self.kmac];
        NSLog(@"hmac for video is: %@",hmac);
        
        // NSLog(@"text1 message after encrypting with IV %@ ::: key before encryption %@",text1,self.kencData);
        
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[FIRAuth auth].currentUser.uid
                                                 senderDisplayName:[FIRAuth auth].currentUser.email
                                                              date:date
                                                              text:EncryptedVideo];
        
        
        [[DataBasics dataBasicsInstance]sendMessage:message convID:self.conversationId macTag:hmac iv:ivStringtoStore];
        [self finishSendingMessageAnimated:YES];
        [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        NSLog(@"Video :%@",message);

    }
//    [picker dismissViewControllerAnimated:YES completion:nil];
//    [self finishSendingMessageAnimated:YES];
}

                               
-(NSString *)encodeToBase64String:(UIImage *)image {
    return [UIImagePNGRepresentation(image) base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
}
                               
-(UIImage *)decodeBase64ToImage:(NSString *)strEncodeData {
    NSData *data = [[NSData alloc]initWithBase64EncodedString:strEncodeData options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [UIImage imageWithData:data];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)errorManagement:(NSString* )title  message:(NSString*) message
{
    
    UIAlertController *alert= [UIAlertController
                               alertControllerWithTitle:title
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                               handler:nil];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                   handler:nil];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}






@end
