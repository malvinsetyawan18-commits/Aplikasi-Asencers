from services.ml_service import (
    predict_sensor
)

from services.yolo_service import (
    predict_visual
)

from services.fusion_service import (
    fusion_decision
)

from services.database_service import (
    save_monitoring
)

from services.notification_service import (
    send_notification
)

def process_monitoring(
    sensor_data,
    image_paths
):

    sensor_result = predict_sensor(
        sensor_data
    )

    print(sensor_result)

    visual_results = []

    for path in image_paths:

        result = predict_visual(path)

        visual_results.append(result)

    print(visual_results)

    fusion_result = fusion_decision(

        sensor_result,

        visual_results
    )

    print(fusion_result)

    final_result = {

        "sensor_result":
        sensor_result,

        "visual_results":
        visual_results,

        "fusion_result":
        fusion_result
    }

    save_monitoring(
        final_result
    )

    send_notification(

        fusion_result["status"]
    )

    return final_result