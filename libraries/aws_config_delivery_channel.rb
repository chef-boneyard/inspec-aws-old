# singleton per region - 0 or 1
# aws configservice describe-delivery-channels
# {
#     "DeliveryChannels": [
#         {
#             "snsTopicARN": "...", <-- sns_topic property
#             "name": "default",
#             "s3BucketName": "..." <-- s3_bucket property
#         }
#     ]
# }
# aws configservice describe-delivery-channel-status
# {
#     "DeliveryChannelsStatus": [
#         {
#             "configStreamDeliveryInfo": {
#                 "lastStatusChangeTime": 1509564104.682,
#                 "lastStatus": "SUCCESS" <-- sns topic delivery status
#             },
#             "configHistoryDeliveryInfo": {
#                 "lastSuccessfulTime": 1509549995.891,
#                 "lastStatus": "SUCCESS", <-- s3 bucket delivery status
#                 "lastAttemptTime": 1509549995.891
#             },
#             "configSnapshotDeliveryInfo": {},
#             "name": "default"
#         }
#     ]
# }