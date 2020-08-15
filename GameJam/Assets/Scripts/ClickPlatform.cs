using System;
using System.Collections.Generic;
using System.Collections;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;

public class ClickPlatform : MonoBehaviour, IPointerClickHandler
{
    public GameObject platform;
    public void OnPointerClick(PointerEventData eventData)
    {
        Debug.Log(gameObject.name);
        Debug.Log("Click");
        platform.GetComponent<Animator>().enabled = true;
    }
    // Start is called before the first frame update
    void Start()
    {
       

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
