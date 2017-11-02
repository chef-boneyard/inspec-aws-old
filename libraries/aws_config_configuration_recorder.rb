# Singleton, 0 or 1 per region
# aws configservice describe-configuration-recorders
# {
#     "ConfigurationRecorders": [
#         {
#             "recordingGroup": {
#                 "allSupported": true, # <-- recording_all_regional_changes?
#                 "resourceTypes": [],
#                 "includeGlobalResourceTypes": false  # <-- recording_all_global_changes?
#             },
#             "roleARN": "...",
#             "name": "default"
#         }
#     ]
# }

# aws configservice describe-configuration-recorder-status
# {
#     "ConfigurationRecordersStatus": [
#         {
#             "name": "default",
#             "lastStatus": "SUCCESS",
#             "recording": true,               # <-- enabled?
#             "lastStatusChangeTime": 1509564105.274,
#             "lastStartTime": 1416511231.663,
#             "lastStopTime": 1415968366.575
#         }
#     ]
# }