# =====================================================
# FUSION ENGINE
# =====================================================

def fusion_decision(

    sensor_result,

    visual_results
):

    sensor_label = sensor_result["label"]

    sensor_conf = sensor_result["confidence"]

    labels = [

        v["label"]

        for v in visual_results
    ]

    # =================================================
    # HITUNG LABEL
    # =================================================

    sehat_count = labels.count(
        "Daun Sehat"
    )

    kuning_count = labels.count(
        "Daun Kekuningan"
    )

    bercak_count = labels.count(
        "Daun Bercak Hitam"
    )

    # =================================================
    # RULE-BASED FUSION
    # =================================================

    # ================================================
    # KEKURANGAN NUTRISI
    # ================================================

    if (

        sensor_label == "Kekurangan Nutrisi"

        and

        kuning_count >= 2

        and

        sensor_conf >= 0.75
    ):

        return {

            "status": (
                "SANGAT YAKIN: "
                "KEKURANGAN NUTRISI"
            ),

            "recommendation": (
                "Tambahkan nutrisi AB Mix "
                "dan cek nilai TDS."
            )
        }

    # ================================================
    # PENYAKIT TANAMAN
    # ================================================

    elif (

        bercak_count >= 2
    ):

        return {

            "status": (
                "WASPADA: "
                "PENYAKIT TANAMAN"
            ),

            "recommendation": (
                "Periksa kemungkinan "
                "jamur atau bakteri."
            )
        }

    # ================================================
    # DAUN KEKUNINGAN
    # ================================================

    elif (

        kuning_count >= 3
    ):

        return {

            "status": (
                "WASPADA: "
                "DAUN KEKUNINGAN"
            ),

            "recommendation": (
                "Periksa pH dan "
                "konsentrasi nutrisi."
            )
        }

    # ================================================
    # KONDISI OPTIMAL
    # ================================================

    elif (

        sehat_count >= 3

        and

        sensor_label == "Normal"
    ):

        return {

            "status": (
                "KONDISI OPTIMAL"
            ),

            "recommendation": (
                "Tanaman dalam kondisi baik."
            )
        }

    # ================================================
    # DEFAULT
    # ================================================

    else:

        return {

            "status": (
                "PERLU PEMANTAUAN LANJUT"
            ),

            "recommendation": (
                "Lakukan monitoring rutin."
            )
        }