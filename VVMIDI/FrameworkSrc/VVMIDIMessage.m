
#import "VVMIDIMessage.h"
#import "VVMIDI.h"




@implementation VVMIDIMessage


- (NSString *) description	{
	return [NSString stringWithFormat:@"<VVMIDIMessage: 0x%X : %d : %d : %d : %d : %llu>",type,channel,data1,data2,data3,timestamp];
}
- (NSString *) lengthyDescription	{
	switch (type)	{
		//	status byte
		case VVMIDINoteOffVal:
			//return [NSString stringWithFormat:@"NoteOff, ch.%hhd, note.%hhd, val.%hhd, time.%qd",channel,data1,data2,timestamp];
			return [NSString stringWithFormat:@"NoteOff, ch.%hhd, note.%hhd, val.%hhd",channel,data1,data2];
			break;
		case VVMIDINoteOnVal:
			//return [NSString stringWithFormat:@"NoteOn, ch.%hhd, note.%hhd, val.%hhd, time.%qd",channel,data1,data2,timestamp];
			return [NSString stringWithFormat:@"NoteOn, ch.%hhd, note.%hhd, val.%hhd",channel,data1,data2];
			break;
		case VVMIDIAfterTouchVal:
			//return [NSString stringWithFormat:@"AfterTouch, ch.%hhd, note.%hhd, val.%hhd, time.%qd",channel,data1,data2,timestamp];
			return [NSString stringWithFormat:@"AfterTouch, ch.%hhd, note.%hhd, val.%hhd",channel,data1,data2];
			break;
		case VVMIDIControlChangeVal:
			//return [NSString stringWithFormat:@"Ctrl, ch.%hhd, ctrl.%hhd, val.%hhd, time.%qd",channel,data1,data2,timestamp];
			return [NSString stringWithFormat:@"Ctrl, ch.%hhd, ctrl.%hhd, val.%hhd",channel,data1,data2];
			break;
		case VVMIDIProgramChangeVal:
			//return [NSString stringWithFormat:@"PgmChange, ch.%hhd, pgm.%hhd, time.%qd",channel,data1,timestamp];
			return [NSString stringWithFormat:@"PgmChange, ch.%hhd, pgm.%hhd",channel,data1];
			break;
		case VVMIDIChannelPressureVal:
			//return [NSString stringWithFormat:@"ChannelPressure, ch.%hhd, val.%hhd, time.%qd",channel,data1,timestamp];
			return [NSString stringWithFormat:@"ChannelPressure, ch.%hhd, val.%hhd",channel,data1];
			break;
		case VVMIDIPitchWheelVal:
			//return [NSString stringWithFormat:@"PitchWheel, ch.%hhd, val.%d, time.%qd",channel,(data2<<7)|data1,timestamp];
			return [NSString stringWithFormat:@"PitchWheel, ch.%hhd, val.%d",channel,(data2<<7)|data1];
			break;
		//	common messages
		case VVMIDIMTCQuarterFrameVal:
			//return [NSString stringWithFormat:@"Quarter-Frame: %hhd, time.%qd",data1,timestamp];
			return [NSString stringWithFormat:@"Quarter-Frame: %hhd",data1];
			break;
		case VVMIDISongPosPointerVal:
			//return [NSString stringWithFormat:@"Song Pos'n ptr: %d, time.%qd",(data2 << 7) | data1,timestamp];
			return [NSString stringWithFormat:@"Song Pos'n ptr: %d",(data2 << 7) | data1];
			break;
		case VVMIDISongSelectVal:
			//return [NSString stringWithFormat:@"Song Select: %hhd, time.%qd",data1,timestamp];
			return [NSString stringWithFormat:@"Song Select: %hhd",data1];
			break;
		case VVMIDIUndefinedCommon1Val:
			return @"Undefined common";
			break;
		case VVMIDIUndefinedCommon2Val:
			return @"Undefined common 2";
			break;
		case VVMIDITuneRequestVal:
			return @"Tune Request";
			break;
		//	sysex!
		case VVMIDIBeginSysexDumpVal:
			return [NSString stringWithFormat:@"Sysex: %@, time.%lli",[self sysexData],timestamp];
			break;
		//	realtime messages- insert these immediately
		case VVMIDIClockVal:
			return @"Clock";
			break;
		case VVMIDITickVal:
			return @"Tick";
			break;
		case VVMIDIStartVal:
			return @"Start";
			break;
		case VVMIDIContinueVal:
			return @"Continue";
			break;
		case VVMIDIStopVal:
			return @"Stop";
			break;
		case VVMIDIUndefinedRealtime1Val:
			return @"Undefined Realtime";
			break;
		case VVMIDIActiveSenseVal:
			return @"Active Sense";
			break;
		case VVMIDIResetVal:
			return @"MIDI Reset";
			break;
	}
	return nil;
}
- (BOOL) isFullFrameSMPTE	{
	if (sysexArray==nil)
		return NO;
	if ([sysexArray count]==8 && 
	[[sysexArray objectAtIndex:0] intValue]==127 &&
	[[sysexArray objectAtIndex:2] intValue]==1 &&
	[[sysexArray objectAtIndex:3] intValue]==1)	{
		return YES;
	}
	return NO;
}


+ (id) createWithType:(Byte)t channel:(Byte)c {
	return [[[VVMIDIMessage alloc] initFromVals:t:c:-1:-1:-1:0] autorelease];
}
+ (id) createWithType:(Byte)t channel:(Byte)c timestamp:(uint64_t)time; {
	return [[[VVMIDIMessage alloc] initFromVals:t:c:-1:-1:-1:time] autorelease];
}
+ (id) createWithSysexArray:(NSMutableArray *)s {
	return [[[VVMIDIMessage alloc] initWithSysexArray:s timestamp:0] autorelease];
}
+ (id) createWithSysexArray:(NSMutableArray *)s timestamp:(uint64_t)time;	{
	return [[[VVMIDIMessage alloc] initWithSysexArray:s timestamp:time] autorelease];
}
+ (id) createWithSysexData:(NSData *)d	{
	return [[[VVMIDIMessage alloc] initWithSysexData:d timestamp:0] autorelease];
}
+ (id) createWithSysexData:(NSData *)d timestamp:(uint64_t)time	{
	return [[[VVMIDIMessage alloc] initWithSysexData:d timestamp:time] autorelease];
}
+ (id) createFromVals:(Byte)t :(Byte)c :(Byte)d1 :(Byte)d2 {
	return [[[VVMIDIMessage alloc] initFromVals:t:c:d1:d2:-1:(uint64_t)0] autorelease];
}
+ (id) createFromVals:(Byte)t :(Byte)c :(Byte)d1 :(Byte)d2 :(Byte)d3 {
	return [[[VVMIDIMessage alloc] initFromVals:t:c:d1:d2:d3:(uint64_t)0] autorelease];
}
+ (id) createFromVals:(Byte)t :(Byte)c :(Byte)d1 :(Byte)d2 :(Byte)d3 :(uint64_t)time	{
	return [[[VVMIDIMessage alloc] initFromVals:t:c:d1:d2:d3:time] autorelease];
}


- (id) initWithType:(Byte)t channel:(Byte)c {
	return [self initFromVals:t :c :-1 :-1 :-1 :0];
}
- (id) initWithType:(Byte)t channel:(Byte)c timestamp:(uint64_t)time	{
	return [self initFromVals:t :c :-1 :-1 :-1 :time];
}
- (id) initWithSysexArray:(NSMutableArray *)s {
	return [self initWithSysexArray:s timestamp:0];
}
- (id) initWithSysexArray:(NSMutableArray *)s timestamp:(uint64_t)time; {
	if ((s==nil)||([s count]<1))
		goto BAIL;
	//	if any vals in sysex array are improperly sized, release & return nil
	for (NSNumber *numPtr in s) {
		if ([numPtr intValue] > 0x7F)	{
			NSLog(@"\terr: bailing, val in passed sysex array (%X) was > 0x7F",[numPtr intValue]);
			goto BAIL;
		}
	}
	
	if (self = [super init])	{
		type = VVMIDIBeginSysexDumpVal;
		channel = -1;
		data1 = -1;
		data2 = -1;
		data3 = -1;
		sysexArray = [s mutableCopy];
		timestamp = time;
		return self;
	}
	BAIL:
	NSLog(@"\t\terr: %s - BAIL",__func__);
	[self release];
	return nil;
}
- (id) initWithSysexData:(NSData *)d	{
	return [self initWithSysexData:d timestamp:0];
}
- (id) initWithSysexData:(NSData *)d timestamp:(uint64_t)time	{
	if (d==nil || [d length]<1)
		goto BAIL;
	
	self = [super init];
	if (self != nil)	{
		type = VVMIDIBeginSysexDumpVal;
		channel = -1;
		data1 = -1;
		data2 = -1;
		data3 = -1;
		sysexArray = [[NSMutableArray arrayWithCapacity:0] retain];
		timestamp = time;
		
		uint8_t			*rPtr = (uint8_t *)[d bytes];
		for (int i=0; i<[d length]; ++i)	{
			//	if any of the vals in the passed sysex blob are improperly sized, release & return nil
			if (*rPtr > 0x7F)	{
				NSLog(@"\t\terr: bailing, val in sysex data (%X) was > 0x7F",*rPtr);
				goto BAIL;
			}
			NSNumber		*tmpNum = [NSNumber numberWithInteger:*rPtr];
			if (tmpNum != nil)
				[sysexArray addObject:tmpNum];
			++rPtr;
		}
		return self;
	}
	BAIL:
	NSLog(@"\t\terr: %s - BAIL",__func__);
	[self release];
	return nil;
}
- (id) initFromVals:(Byte)t :(Byte)c :(Byte)d1 :(Byte)d2 {
	return [self initFromVals:t :c :d1 :d2 :-1 :0];
}
- (id) initFromVals:(Byte)t :(Byte)c :(Byte)d1 :(Byte)d2 :(Byte)d3 {
	return [self initFromVals:t :c :d1 :d2 :d3 :0];
}
- (id) initFromVals:(Byte)t :(Byte)c :(Byte)d1 :(Byte)d2 :(Byte)d3 :(uint64_t)time	{
	if (self = [super init])	{
		type = t;
		channel = c;
		data1 = d1;
		data2 = d2;
		data3 = d3;
		sysexArray = nil;
		timestamp = time;
		return self;
	}
	[self release];
	return nil;
}


- (id) copyWithZone:(NSZone *)z	{
	VVMIDIMessage		*copy = nil;
	if (type == VVMIDIBeginSysexDumpVal)
		copy = [[[self class] allocWithZone:z] initWithSysexArray:sysexArray timestamp:timestamp];
	else
		copy = [[[self class] allocWithZone:z] initFromVals:type :channel :data1 :data2 :data3 :timestamp];
	return copy;
	/*
	VVMIDIMessage		*copy = [[[self class] allocWithZone:z] initWithType:type channel:channel];
	[copy setData1:data1];
	[copy setData2:data2];
	return copy;
	*/
}


- (void) dealloc	{
	if (sysexArray != nil)	{
		[sysexArray release];
		sysexArray = nil;
	}
	[super dealloc];
}


- (Byte) type	{
	return type;
}
- (void) setType:(Byte)newType	{
	type = newType;
}
- (Byte) channel	{
	return channel;
}
- (void) setData1:(Byte)newData	{
	data1 = newData;
}
- (Byte) data1	{
	return data1;
}
- (void) setData2:(Byte)newData	{
	data2 = newData;
}
- (Byte) data2	{
	return data2;
}
- (void) setData3:(Byte)newData	{
	data3 = newData;
}
- (Byte) data3	{
	return data3;
}
- (NSMutableArray *) sysexArray	{
	return sysexArray;
}
- (NSMutableData *) sysexData	{
	size_t			dataSize = (sysexArray==nil) ? 0 : [sysexArray count];
	NSMutableData	*returnMe = (dataSize==0) ? nil : [[NSMutableData alloc] initWithLength:dataSize];
	uint8_t			*wPtr = (uint8_t *)[returnMe mutableBytes];
	for (int i=0; i<dataSize; ++i)	{
		NSNumber		*tmpNum = [sysexArray objectAtIndex:i];
		*wPtr = (tmpNum==nil) ? 0 : [tmpNum intValue];
		++wPtr;
	}
	return (returnMe==nil) ? nil : [returnMe autorelease];
}
- (void) setTimestamp:(uint64_t)newTimestamp {
	timestamp = newTimestamp;
}
- (uint64_t) timestamp	{
	return timestamp;
}
- (double) doubleValue	{
	//NSLog(@"%s ... %@",__func__,self);
	double		returnMe = 0.0;
	if (data3<0 || data3>127)	{
		//NSLog(@"\t\t7-bit, %d",data2);
		returnMe = (double)((double)data2/(double)127.0);
	}
	else	{
		//NSLog(@"\t\t14-bit, %d / %d, %f",data2,data3,((double)((((long)data2 & 0x7F)<<7) | ((long)data3 & 0x7F))/16383.0));
		returnMe = (double)((double)((((long)data2 & 0x7F)<<7) | ((long)data3 & 0x7F))/(double)16383.0);
	}
	//NSLog(@"\t\treturning %0.32f",returnMe);
	return returnMe;
}


@end
