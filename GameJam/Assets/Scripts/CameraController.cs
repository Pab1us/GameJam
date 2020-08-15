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
        if (Input.GetMouseButtonDown(0)) startPosition = cam.ScreenToViewportPoint(Input.mousePosition);
        else if (Input.GetMouseButtonDown(0))
        {
            float pos = cam.ScreenToViewportPoint(Input.mousePosition).x - startPosition.x;
            transform.position = new Vector3(Mathf.Clamp(transform.position.x - pos, -50.0f, 50.0f), transform.position.y, transform.position.z);
        }
    }
}
