using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class ButtonController : MonoBehaviour
{
    public Text coin;
    public Text coin2;
    public Text coin3;
    public Text coin4;
    public Image panel1;
    public Image panel2;
    public Image panel3;
    public Image panel4;

    // Start is called before the first frame update
    void Start()
    {
        //panel3.gameObject.SetActive(false);
        //panel4.gameObject.SetActive(false);
        //coin.text = Globals.coins.ToString();
    }

    // Update is called once per frame
    void Update()
    {
       // coin.text = Globals.coins.ToString();
    }

    public void btnExtit()
    {
        SceneManager.LoadScene(0);
    }
    public void btnShowFinish()
    {
        coin3.text = Globals.coins.ToString();
        panel3.gameObject.SetActive(true);
        panel4.gameObject.SetActive(false);
    }
    public void btnShowOut()
    {
        coin4.text = Globals.coins.ToString();
        panel3.gameObject.SetActive(false);
        panel4.gameObject.SetActive(true);
    }

    public void btnPlay()
    {
        SceneManager.LoadScene(1);
    }
    public void btnPlay2()
    {
        SceneManager.LoadScene(2);
    }
    public void btnNext()
    {
        panel1.gameObject.SetActive(false);
        panel2.gameObject.SetActive(true);
    }
    
   

}
