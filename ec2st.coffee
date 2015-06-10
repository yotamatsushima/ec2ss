AWS = require "aws-sdk"
AWS.config.update {region: "ap-northeast-1"}
ec2 = new AWS.EC2

TAGVALUE = 'autss'

#listen slack command "goodbye aws" or "hello aws"
module.exports = (robot) ->
  robot.hear /goodbye aws|hello aws/,(msg) ->
    ec2.describeInstances null,(err,data) ->
      if err
        console.log err, err.stack
        return

      #get target Instances
      instances=  getInstances data.Reservations

      #StopInstances(tags-value 'autss')
      if msg.envelope.message.text is 'goodbye aws'
        ec2.stopInstances {InstanceIds:instances},(err,data) ->
          if err
            console.log err,err.stack
          else
            console.log data
            msg.reply "stop instances!!!"

      #Start Instances(tag-value 'autss')
      if msg.envelope.message.text is 'hello aws'
        ec2.startInstances {InstanceIds:instances},(err,data) ->
          if err
            console.log err,err.stack
          else
            console.log data
            msg.reply "start instances!!!"

# This function will get every Instances of Tags Name is 'autss'
getInstances = (reservs) ->
  instances = new Array
  for resvobj in reservs
    for instobj in resvobj.Instances
      for tag in instobj.Tags
        if tag.Value is TAGVALUE
           instances.push instobj.InstanceId
   return instances