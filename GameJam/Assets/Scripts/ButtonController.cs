using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class ButtonController : MonoBehaviour
{
    public Text coin;
    public Sprite litleMuk;
    public Sprite indianaJons;
    public Sprite laraCroft;
    public Sprite montyHoll;
    public Sprite nostradama;
    public Image heroes;
    public Image panel;
    public Text info;
    public Image panel1;
    public Image panel2;

    // Start is called before the first frame update
    void Start()
    {
        coin.text = Globals.coins.ToString();
    }

    // Update is called once per frame
    void Update()
    {
        coin.text = Globals.coins.ToString();
    }

    public void btnExtit()
    {
        SceneManager.LoadScene(0);
    }

    public void btnPlay()
    {
        SceneManager.LoadScene(1);
    }
    public void btnNext()
    {
        panel1.gameObject.SetActive(false);
        panel2.gameObject.SetActive(true);
    }
    public void btnRandomPers()
    {
        panel.gameObject.SetActive(true);
        System.Random rand = new System.Random();
        int mode = rand.Next(1, 6);
        if (mode == 1)
        {
            Globals.mainCharacter = "litleMuk";
            heroes.GetComponent<Image>().sprite = litleMuk;
            info.GetComponent<Text>().text = "визуально - хил и слаб, уродец-торговецнайденные сокровища умножатся x1.53 слота под шмотки";
        }
        if (mode == 2)
        {
            Globals.mainCharacter = "indianaJons";
            heroes.GetComponent<Image>().sprite = indianaJons;
            info.GetComponent<Text>().text = "визуально - приключенецпри попадании в ловушку теряет только половину сокровищ2 слота под шмотки";
        }
        if (mode == 3)
        {
            heroes.GetComponent<Image>().sprite = laraCroft;
            Globals.mainCharacter = "laraCroft";
            info.GetComponent<Text>().text = "визуально - ловкая, может избежать последствий попадания в одну ловушку(с перезарядкой)1 слот под шмотки";
        }
        if (mode == 4)
        {
            heroes.GetComponent<Image>().sprite = montyHoll;
            Globals.mainCharacter = "montyHoll";
            info.GetComponent<Text>().text = "визуально - ученый,если перед ним 3 клетки, может посмотреть(вскрыть) одну из них, и после этого принять решение, куда двигаться. 2 слота под шмотки";
        }
        if (mode == 5)
        {
            heroes.GetComponent<Image>().sprite = nostradama;
            Globals.mainCharacter = "nostradama";
            info.GetComponent<Text>().text = "визуально - предсказательница-цыганка? с 25 % -й вероятностью знает, в каком гексе перед ней ловушка1 слот для шмотки";
        }

   
    }

}
