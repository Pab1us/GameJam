using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraController : MonoBehaviour
{

    private Vector3 startPosition;
    public Camera cam;

    private void Start()
    {
        cam = GetComponent<Camera>();
    }

    private void Update()
    {
        //получаем позицию при старте клика
        if (Input.GetMouseButtonDown(2))
        {
            startPosition = cam.ScreenToViewportPoint(Input.mousePosition);
        }

        //пока держат левую кнопку мыши
        if (Input.GetMouseButton(2))
        {
            //вычисляем дельту по х
            float pos = cam.ScreenToViewportPoint(Input.mousePosition).x - startPosition.x;
            //отнимаем дельту, для инвертированного движения
            transform.position = new Vector3(Mathf.Clamp(transform.position.x - pos, -5.0f, 0.0f), transform.position.y, transform.position.z);
        }
    }
}
